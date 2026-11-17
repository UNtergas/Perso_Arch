-- Keep Lspsaga's symbols and styling, but render for each window's actual buffer and cursor.
local M = {}
local api = vim.api
local expression = "%!v:lua.saga_breadcrumb()"
local ticks = {}

local function contains(range, row, col)
  local first, last = range.start, range["end"]
  return (row > first.line or row == first.line and col >= first.character)
    and (row < last.line or row == last.line and col < last.character)
end

-- Servers may return unsorted siblings. Compare complete ranges, including columns and exclusive ends.
function M.path(symbols, row, col, uri)
  local best, best_span = {}, math.huge
  for _, node in ipairs(symbols or {}) do
    local range = node.range or node.location and node.location.range
    if range and (not node.location or not node.location.uri or node.location.uri == uri)
      and contains(range, row, col) then
      local path = { node }
      vim.list_extend(path, M.path(node.children, row, col, uri))
      local span = (range["end"].line - range.start.line) * 1000000
        + range["end"].character - range.start.character
      if #path > #best or #path == #best and span < best_span then best, best_span = path, span end
    end
  end
  return best
end

local function eligible(win, buf)
  return api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == ""
    and vim.bo[buf].filetype ~= "oil" and api.nvim_buf_get_name(buf) ~= ""
end
local function escape(s) return s:gsub("%%", "%%%%"):gsub("[\r\n]", " ") end

function M.render(win)
  win = win or tonumber(vim.g.statusline_winid) or api.nvim_get_current_win()
  if not api.nvim_win_is_valid(win) then return "" end
  local buf = api.nvim_win_get_buf(win)
  if not eligible(win, buf) then return "" end
  -- vim-visual-multi is on in this window: show its info (mode, cursor n / total, search patterns) here instead of the
  -- breadcrumb, so the statusline stays as it is (g:VM_set_statusline = 0). The breadcrumb is back when VM exits.
  if win == api.nvim_get_current_win() and vim.b[buf].visual_multi then
    local ok, bar = pcall(vim.fn["vm#themes#statusline"])
    if ok and bar ~= "" then return bar end
  end
  local filename = vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ":t")
  local icon = require("nvim-web-devicons").get_icon(filename, nil, { default = true }) or ""
  local parts = { "%#SagaFileName#" .. icon .. " " .. escape(filename) .. "%*" }
  local symbol = require("lspsaga.symbol.head")
  local state = symbol:get_buf_symbols(buf)
  if state and state.symbols and ticks[buf] == api.nvim_buf_get_changedtick(buf) then
    local cursor = api.nvim_win_get_cursor(win)
    local owner = symbol[buf] and vim.lsp.get_client_by_id(symbol[buf].client_id)
    local encoding = owner and owner.offset_encoding or "utf-16"
    local line = api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1] or ""
    local col = vim.str_utfindex(line, encoding, cursor[2], false)
    for _, node in ipairs(M.path(state.symbols, cursor[1] - 1, col, vim.uri_from_bufnr(buf))) do
      local kind = require("lspsaga.lspkind").get_kind_icon(node.kind)
      if node.containerName then parts[#parts + 1] = "%#SagaClass#" .. escape(node.containerName) .. "%*" end
      parts[#parts + 1] = "%#Saga" .. kind[1] .. "#" .. kind[2] .. escape(node.name) .. "%*"
    end
  end
  return "%<" .. table.concat(parts, "%#SagaSep# › %*")
end

function M.install(buf)
  for _, win in ipairs(api.nvim_list_wins()) do
    local b = api.nvim_win_get_buf(win)
    if not buf or b == buf then
      if eligible(win, b) and not vim.w[win].saga_breadcrumb_hidden then
        vim.wo[win].winbar = expression
      elseif vim.wo[win].winbar == expression then
        vim.wo[win].winbar = ""
      end
    end
  end
end

function M.setup()
  _G.saga_breadcrumb = function() return M.render() end
  local winbar = require("lspsaga.symbol.winbar")
  winbar.init_winbar = M.install
  winbar.get_bar = M.render
  winbar.toggle = function()
    vim.w.saga_breadcrumb_hidden = not vim.w.saga_breadcrumb_hidden
    M.install(api.nvim_get_current_buf())
  end
  local group = api.nvim_create_augroup("SagaBreadcrumbRefresh", { clear = true })
  api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufFilePost", "FileType" }, {
    group = group, callback = function() M.install() end,
  })
  api.nvim_create_autocmd("User", {
    group = group, pattern = "SagaSymbolUpdate", callback = function(ev)
      local buf = ev.data and ev.data.bufnr
      if buf and api.nvim_buf_is_valid(buf) then
        ticks[buf] = api.nvim_buf_get_changedtick(buf)
        M.install(buf)
        vim.cmd("redrawstatus")
      end
    end,
  })
  api.nvim_create_autocmd("BufWipeout", { group = group, callback = function(ev) ticks[ev.buf] = nil end })
  -- redraw the bar when VM starts / ends and while it is on (cursor moves, mode changes, typing), so its info stays current
  api.nvim_create_autocmd("User", {
    group = group, pattern = { "visual_multi_start", "visual_multi_exit" }, callback = function() vim.cmd("redrawstatus") end,
  })
  api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "TextChangedI" }, {
    group = group, callback = function() if vim.b.visual_multi then vim.cmd("redrawstatus") end end,
  })
  M.install()
end
return M
