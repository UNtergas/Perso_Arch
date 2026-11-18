-- The winbar of every file window: icon, path, unsaved dot and the file's own git counts on the left; on the focused
-- window the harpoon slots on the right. (The name is historic: it used to be Lspsaga's symbol breadcrumb, now gone.)
-- While vim-visual-multi is on in the window, VM's info (mode, cursor n / total, patterns) takes the bar instead.
-- It still replaces Lspsaga's winbar functions so Lspsaga never writes its own.
local M = {}
local api = vim.api
local expression = "%!v:lua.saga_breadcrumb()"

local function eligible(win, buf)
  if api.nvim_win_get_config(win).relative ~= "" then return false end
  local name = api.nvim_buf_get_name(buf)
  if name == "" then return false end
  if vim.bo[buf].buftype == "" then return vim.bo[buf].filetype ~= "oil" end
  return _G.githist_label ~= nil and _G.githist_label(name) ~= nil -- old file versions (githist://)
end
local function escape(s) return s:gsub("%%", "%%%%"):gsub("[\r\n]", " ") end

local function colors()
  local bar = api.nvim_get_hl(0, { name = "WinBar", link = false })
  local bg = bar.bg or 0xfafafa
  api.nvim_set_hl(0, "HarpSlot", { fg = 0x6a6a6a, bg = bg })
  api.nvim_set_hl(0, "HarpSlotSel", { fg = 0x1d2b2a, bg = bg, bold = true, underline = true })
  api.nvim_set_hl(0, "BarModified", { fg = 0x1f4e9c, bg = bg })
  api.nvim_set_hl(0, "BarPath", { link = "Comment" }) -- the path takes the theme's comment colour
end

local function harpoon_slots(buf)
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then return "" end
  local items = harpoon:list().items
  if #items == 0 then return "" end
  local current = vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ":.")
  local parts = { "%#HarpSlot#[\u{f0031}]" } -- [󰀱] then one slot each, the current file's slot highlighted
  for i, item in ipairs(items) do
    parts[#parts + 1] = (item.value == current and "%#HarpSlotSel#" or "%#HarpSlot#") .. "[" .. i .. "]"
  end
  return table.concat(parts, " ") .. "%#WinBar# "
end

function M.render(win)
  win = win or tonumber(vim.g.statusline_winid) or api.nvim_get_current_win()
  if not api.nvim_win_is_valid(win) then return "" end
  local buf = api.nvim_win_get_buf(win)
  if not eligible(win, buf) then return "" end
  local focused = win == api.nvim_get_current_win()
  if focused and vim.b[buf].visual_multi then
    local ok, bar = pcall(vim.fn["vm#themes#statusline"])
    if ok and bar ~= "" then return bar end
  end
  local name = api.nvim_buf_get_name(buf)
  local label = _G.githist_label and _G.githist_label(name)
  local path = label or vim.fn.fnamemodify(name, ":~:.")
  -- the icon has its own devicons colour, the same as in Oil and Telescope
  local icon, icon_hl = require("nvim-web-devicons").get_icon(vim.fn.fnamemodify(name, ":t"), nil, { default = true })
  icon = icon or ""
  local mod = vim.bo[buf].modified
  local left = " %#" .. (icon_hl or "SagaFileName") .. "#" .. icon .. " %<" .. (mod and "%#BarModified#" or "%#BarPath#") .. escape(path)
    .. (mod and " \u{f444}" or "") .. "%#WinBar#" .. (_G.diff_status and _G.diff_status(buf) or "") .. "%#WinBar#"
  return left .. "%=" .. (focused and harpoon_slots(buf) or "")
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
  colors()
  local group = api.nvim_create_augroup("SagaBreadcrumbRefresh", { clear = true })
  api.nvim_create_autocmd("ColorScheme", { group = group, callback = colors })
  api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufFilePost", "FileType" }, {
    group = group, callback = function() M.install() end,
  })
  -- the path, dot and counts follow the buffer: redraw when it is edited or saved, when git signs update and when the
  -- harpoon list changes (those two already redraw the status area; BufModifiedSet is the new one)
  api.nvim_create_autocmd("BufModifiedSet", { group = group, callback = function() vim.cmd.redrawstatus() end })
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
