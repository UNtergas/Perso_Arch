-- Augment only this Kotlin client's definition responses, so gd and UI plugins share fallbacks.
local M = {}

-- gd on a view/data binding class or one of its fields lands in the generated Java under <module>/build/generated/
-- data_binding_base_class_source_out; Android Studio opens the layout instead. Map: ActivityMainBinding -> activity_main.xml,
-- the field tokenInput -> the line with android:id="@+id/token_input" in that layout. Anything unmatched is left alone.
local function read_lines(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and lines or nil
end

local function layout_for(module, name)
  local layouts = vim.fn.glob(module .. "/src/*/res/layout/" .. name .. ".xml", false, true)
  if #layouts == 0 then layouts = vim.fn.glob(module .. "/src/*/res/layout*/" .. name .. ".xml", false, true) end
  return layouts[1]
end

function M.generated_to_layout(loc)
  local uri = loc.targetUri or loc.uri
  local range = loc.targetSelectionRange or loc.range
  if not uri or not range then return loc end
  local file = vim.uri_to_fname(uri)
  local module = file:match("^(.-)/build/generated/data_binding_base_class_source_out/")
  if not module or not file:match("Binding%.java$") then return loc end
  local lines = read_lines(file)
  local text = lines and lines[range.start.line + 1]
  if not text then return loc end
  local function at(xml, line, col)
    local pos = { line = line, character = col }
    return { uri = vim.uri_from_fname(xml), range = { start = pos, ["end"] = pos } }
  end
  local class = text:match("class%s+(%w+)Binding%f[%W]")
  if class then
    local xml = layout_for(module, (class:gsub("(%l)(%u)", "%1_%2"):gsub("(%u)(%u%l)", "%1_%2"):lower()))
    return xml and at(xml, 0, 0) or loc
  end
  local field = text:match("public final [%w%.<>]+ (%w+);")
  if field then
    local layout = file:match("/(%w+)Binding%.java$")
    local xml = layout and layout_for(module, (layout:gsub("(%l)(%u)", "%1_%2"):gsub("(%u)(%u%l)", "%1_%2"):lower()))
    local id = field:gsub("(%u)", "_%1"):lower()
    for i, l in ipairs(xml and read_lines(xml) or {}) do
      local col = l:find('@+id/' .. id .. '"', 1, true) or l:find('@id/' .. id .. '"', 1, true)
      if col then return at(xml, i - 1, col - 1) end
    end
  end
  return loc
end

local function rewrite_generated(result)
  if not vim.islist(result) then return result end
  local out = {}
  for i, loc in ipairs(result) do out[i] = M.generated_to_layout(loc) end
  return out
end

function M.attach(client, opts)
  if client._kvim_definition_fix then return end
  client._kvim_definition_fix = true
  local request, cancel = client.request, client.cancel_request
  local pending = {}
  client.cancel_request = function(self, id)
    local state = pending[id]
    if state then
      state.cancelled = true
      pending[id] = nil
      if state.fallback_id then cancel(self, state.fallback_id) end
    end
    return cancel(self, id)
  end
  client.request = function(self, method, params, handler, bufnr)
    if method == "workspace/symbol" and handler then
      local inner = handler
      handler = function(err, result, ctx, config)
        if type(result) == "table" then opts.fill_ranges(result, self.offset_encoding) end
        return inner(err, result, ctx, config)
      end
    end
    if method ~= "textDocument/definition" or not handler then
      return request(self, method, params, handler, bufnr)
    end
    local buf = bufnr and bufnr ~= 0 and bufnr or vim.uri_to_bufnr(params.textDocument.uri)
    local state = {}
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local line = vim.api.nvim_buf_get_lines(buf, params.position.line, params.position.line + 1, false)[1] or ""
    local col = vim.str_byteindex(line, self.offset_encoding, params.position.character, false)
    local word, from = "", 0
    while from <= #line do
      local match = vim.fn.matchstrpos(line, [[\k\+]], from)
      if match[2] < 0 then break end
      if match[2] <= col and col < match[3] then word = match[1]; break end
      from = match[3]
    end
    local function valid()
      return not state.cancelled and vim.api.nvim_buf_is_valid(buf)
        and vim.api.nvim_buf_get_changedtick(buf) == tick
    end
    local function finish(err, result, ctx, config)
      state.done = true
      if state.id then pending[state.id] = nil end
      if not state.cancelled then handler(err, result, ctx, config) end
    end
    local function deliver(result, ctx, config)
      result = rewrite_generated(result)
      if vim.islist(result) and #result > 1 then
        vim.ui.select(result, {
          prompt = "Definitions of " .. word,
          format_item = function(loc)
            local range = loc.targetSelectionRange or loc.range
            return vim.fn.fnamemodify(vim.uri_to_fname(loc.targetUri or loc.uri), ":~:.")
              .. ":" .. (range.start.line + 1)
          end,
        }, function(loc)
          finish(nil, valid() and loc and { loc } or {}, ctx, config)
        end)
      else
        finish(nil, result, ctx, config)
      end
    end
    local ok, id = request(self, method, params, function(err, result, ctx, config)
      if not valid() then return finish(nil, {}, ctx, config) end
      if not err and result and next(result) then return deliver(result, ctx, config) end
      if word == "" then return finish(err, result, ctx, config) end
      local function use_library()
        if not valid() then return finish(nil, {}, ctx, config) end
        local loc = opts.library(word, buf, self.offset_encoding)
        return finish(nil, loc and { loc } or {}, ctx, config)
      end
      local sent, fallback_id = request(self, "workspace/symbol", { query = word }, function(symbol_err, symbols)
        if not valid() then return finish(nil, {}, ctx, config) end
        local locations = {}
        if not symbol_err and type(symbols) == "table" then
          opts.fill_ranges(symbols, self.offset_encoding)
          for _, symbol in ipairs(symbols) do
            local loc = symbol.location
            if symbol.name == word and loc and loc.uri and loc.range then locations[#locations + 1] = loc end
          end
        end
        if #locations > 0 then return deliver(locations, ctx, config) end
        return use_library()
      end, buf)
      state.fallback_id = fallback_id
      if not sent then use_library() end
    end, buf)
    state.id = id
    if ok and not state.done then pending[id] = state end
    return ok, id
  end
end

return M
