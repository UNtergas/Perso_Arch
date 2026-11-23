-- Better Comments for nvim (like the VS Code extension): a comment whose text starts with a symbol is coloured to the end of the line.
--
--   // ! alert          red, bold
--   // ? question       blue
--   // * highlight      green
--   // TODO / FIXME     orange, bold
--   // // old code      grey, struck through (the comment leader repeated)
--
-- The symbol goes after the comment leader and needs a space before it and after it ("// ! x", "# ? x", "-- * x", " * ! x" inside a
-- /* block */). "//! x" and "#!/bin/sh" are left alone, so Rust inner docs and shebangs are not touched. The leader comes from
-- 'commentstring' (plus a few common ones), the text must really be inside a comment (treesitter says so), and a line comment after
-- code ("foo() // ! x") works too. Nothing is stored in the buffer: the marks are drawn while redrawing, only for the lines on screen.
local M = {}

local ns = vim.api.nvim_create_namespace("better_comments")

local COLORS = {
  BetterCommentAlert = { fg = "#c0262d", bold = true },
  BetterCommentQuery = { fg = "#1f6fc9" },
  BetterCommentHighlight = { fg = "#2e8b3d" },
  BetterCommentTodo = { fg = "#d97706", bold = true },
  BetterCommentStrike = { fg = "#8a8a8a", strikethrough = true },
}
local SYMBOL = { ["!"] = "BetterCommentAlert", ["?"] = "BetterCommentQuery", ["*"] = "BetterCommentHighlight" }
local DEFAULT_LEADERS = { "//", "#", "--", ";", '"', "%", "<!--", "/*" }

function M.colors()
  for name, def in pairs(COLORS) do vim.api.nvim_set_hl(0, name, def) end
end

local leaders_cache = {}
local function leaders_for(buf)
  local cs = vim.bo[buf].commentstring or ""
  local key = vim.bo[buf].filetype .. "\0" .. cs
  if leaders_cache[key] then return leaders_cache[key] end
  local list, seen = {}, {}
  local left = vim.trim((cs:match("^(.-)%%s") or ""))
  for _, l in ipairs({ left, unpack(DEFAULT_LEADERS) }) do
    if l ~= "" and not seen[l] then seen[l] = true; list[#list + 1] = l end
  end
  leaders_cache[key] = { list = list, primary = left }
  return leaders_cache[key]
end

-- is (row, col), both 0-based, inside a comment? nil = cannot tell (no parser or no highlight query for this filetype)
local function in_comment(buf, row, col)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, nil, { error = false })
  if not ok or not parser then return nil end
  local lang = parser:lang()
  if not vim.treesitter.query.get(lang, "highlights") then return nil end
  local ok2, caps = pcall(vim.treesitter.get_captures_at_pos, buf, row, col)
  if not ok2 then return nil end
  for _, c in ipairs(caps) do
    if c.capture:find("comment", 1, true) then return true end
  end
  return false
end

-- No parser: guess. Is the text at 0-based index `idx` of the line inside a string? (an odd number of quotes before it)
local function in_string_guess(line, idx)
  local before = line:sub(1, idx)
  for _, q in ipairs({ '"', "'" }) do
    local n = 0
    for pos in before:gmatch("()" .. q) do
      if before:sub(pos - 1, pos - 1) ~= "\\" then n = n + 1 end
    end
    if n % 2 == 1 then return true end
  end
  return false
end

-- No parser: is `row` inside a /* block */ ? Look upward for the nearest "/*" (inside) or "*/" (closed).
local function in_block_guess(buf, row)
  local first = math.max(0, row - 200)
  local lines = vim.api.nvim_buf_get_lines(buf, first, row, false)
  for i = #lines, 1, -1 do
    local l = lines[i]
    if l:find("%*/") then return false end
    if l:find("/%*") then return true end
  end
  return false
end

--- Marks for one line: a list of { col, end_col, group } (0-based, end exclusive). Public so it can be tested without a redraw.
function M.scan(buf, row, line)
  line = line or vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  if not line or #line > 2000 or not line:find("[!?*TF/#%-;\"%%]") then return {} end
  local out = {}
  local function add(col, group) out[#out + 1] = { col = col, end_col = #line, group = group } end

  -- block-comment continuation: "   * ! text" (the " *" is the leader)
  local s, e = line:find("^%s*%*%s+")
  local ic0 = s and in_comment(buf, row, e)
  if s and (ic0 == true or (ic0 == nil and in_block_guess(buf, row))) then
    local rest = line:sub(e + 1)
    local sym = rest:match("^([!?*])%s")
    if sym then add(e, SYMBOL[sym]); return out end
    if rest:match("^TODO%f[%W]") or rest:match("^FIXME%f[%W]") then add(e, "BetterCommentTodo"); return out end
  end

  local cfg = leaders_for(buf)
  for _, leader in ipairs(cfg.list) do
    local init = 1
    while true do
      local ls, le = line:find(leader, init, true)
      if not ls then break end
      init = le + 1
      local sp = line:match("^%s+", le + 1)
      -- treesitter says "comment" -> accept; no parser for this filetype -> only the buffer's own comment leader
      local ic = sp and in_comment(buf, row, ls - 1)
      if sp and (ic == true or (ic == nil and leader == cfg.primary and not in_string_guess(line, ls - 1))) then
        local col = le + #sp                      -- 0-based column of the first char after the spaces
        local rest = line:sub(col + 1)
        local sym = rest:match("^([!?*])%s") or rest:match("^([!?*])$")
        if sym then
          add(col, SYMBOL[sym]); return out
        elseif rest:match("^TODO%f[%W]") or rest:match("^FIXME%f[%W]") then
          add(col, "BetterCommentTodo"); return out
        elseif #rest > #leader and rest:sub(1, #leader) == leader then   -- "// // old code"
          add(col, "BetterCommentStrike"); return out
        end
      end
    end
  end
  return out
end

local enabled = true
function M.setup()
  M.colors()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = M.colors })
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, _, buf)
      return enabled and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= ""
    end,
    on_line = function(_, _, buf, row)
      for _, m in ipairs(M.scan(buf, row)) do
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, m.col, {
          end_col = m.end_col, hl_group = m.group, priority = 4000, ephemeral = true,
        })
      end
    end,
  })
  vim.api.nvim_create_user_command("BetterComments", function()
    enabled = not enabled
    vim.cmd("redraw!")
    vim.notify("Better comments " .. (enabled and "on" or "off"))
  end, { desc = "Toggle the ! ? * TODO comment colours" })
end

return M
