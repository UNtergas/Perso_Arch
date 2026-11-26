-- The winbar of every file window: the project block, then the path, unsaved dot and the file's own git counts on the left; (the harpoon slots are in the tab row, init.lua). (The name is historic: it used to be Lspsaga's symbol breadcrumb, now gone.)
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

-- The project block takes the colour of the mode block of the statusline (insert green, visual blue, replace yellow, command
-- purple); in normal mode it keeps the lighter utf-8 grey-teal.
local PATH_BG = "#211f1d" -- the path block: lighter than the tab row (#100f0e), a step lighter than the bar (#161920)
-- the file type's icon in its own colour (nvim-web-devicons), on the path block's background; one highlight group per colour
local icon_groups = {}
local function file_icon(name)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then return "" end
  local file = vim.fn.fnamemodify(name, ":t")
  local icon, color = devicons.get_icon_color(file, vim.fn.fnamemodify(file, ":e"), { default = true })
  if not icon then return "" end
  local group = "BarIcon" .. (color or ""):gsub("#", "")
  if not icon_groups[group] then
    icon_groups[group] = true
    api.nvim_set_hl(0, group, { fg = color, bg = PATH_BG })
  end
  return "%#" .. group .. "#" .. icon .. " "
end
local mode_key = { n = "normal", i = "insert", v = "visual", V = "visual", ["\22"] = "visual", s = "visual", S = "visual", R = "replace", c = "command", t = "insert" }
function M.project_colors()
  local key = mode_key[api.nvim_get_mode().mode:sub(1, 1)] or "normal"
  local a = _G.mode_a and _G.mode_a[key]
  local bg = (key ~= "normal" and a and a.bg) or "#8fabc4"
  local fg = (key ~= "normal" and a and a.fg) or "#161514"
  if vim.g.resize_mode then bg, fg = "#eab06e", "#161514" end -- C-w r: the peach of tmux's RESIZE label
  local bar = api.nvim_get_hl(0, { name = "WinBar", link = false }).bg
  api.nvim_set_hl(0, "BarProject", { fg = fg, bg = bg, bold = true })
  api.nvim_set_hl(0, "BarProjectArrow", { fg = bg, bg = PATH_BG }) -- project block > path block
  api.nvim_set_hl(0, "BarProjectArrowEnd", { fg = bg, bg = bar }) -- project block > bar (nothing after it)
end

local function colors()
  local bar = api.nvim_get_hl(0, { name = "WinBar", link = false })
  local bg = bar.bg or 0x282828
  api.nvim_set_hl(0, "BarModified", { fg = 0xe0d48e, bg = PATH_BG })
  -- the path takes the theme's comment colour, on its own light background, ending with an arrow into the bar
  api.nvim_set_hl(0, "BarPath", { fg = 0xb8b1a6, bg = PATH_BG })
  -- error (red) / warning (amber) count, on the path block; the same red as the old tab indicator
  local err = api.nvim_get_hl(0, { name = "DiagnosticError", link = false }).fg or 0xf43753
  api.nvim_set_hl(0, "BarDiagError", { fg = err, bg = PATH_BG, bold = true })
  api.nvim_set_hl(0, "BarDiagWarn", { fg = 0xe0d48e, bg = PATH_BG, bold = true })
  api.nvim_set_hl(0, "BarPathArrow", { fg = PATH_BG, bg = bg })
  M.project_colors()
end

-- one indicator at a time: the error count if the buffer has errors, else the warning count, else nothing
local function diag_indicator(buf)
  local S = vim.diagnostic.severity
  local c = vim.diagnostic.count(buf, { severity = { S.ERROR, S.WARN } })
  if (c[S.ERROR] or 0) > 0 then return " %#BarDiagError#\u{f057} " .. c[S.ERROR] end
  if (c[S.WARN] or 0) > 0 then return " %#BarDiagWarn#\u{f071} " .. c[S.WARN] end
  return ""
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
  local mod = vim.bo[buf].modified
  -- [ project]>path : the project (folder name of the window's cwd) is a block with a folder icon, then the path
  local project = vim.fn.fnamemodify(vim.fn.getcwd(vim.fn.win_id2win(win)), ":t")
  local left = "%#BarProject# \u{f024b} " .. escape(project) .. " %#BarProjectArrow#\u{e0b0}%<%#BarPath# " .. (label and "" or file_icon(name)) .. (mod and "%#BarModified#" or "%#BarPath#") .. escape(path)
    .. (mod and " \u{f444}" or "") .. diag_indicator(buf) .. " %#BarPathArrow#\u{e0b0}%#WinBar#" .. (_G.diff_status and _G.diff_status(buf) or "") .. "%#WinBar#"
  return left
end

-- The winbar of an Oil window: the same project block, then the folder being browsed relative to the project (~/... outside it;
-- nothing at the project root). Called by _G.oil_winbar in init.lua.
function M.oil_bar(win)
  win = win or tonumber(vim.g.statusline_winid) or api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local project = vim.fn.fnamemodify(vim.fn.getcwd(vim.fn.win_id2win(win)), ":t")
  local ok, oil = pcall(require, "oil")
  local dir = ok and oil.get_current_dir(buf)
  local path
  if dir then
    path = vim.fn.fnamemodify(dir, ":~:."):gsub("/$", "")
    if path == "." then path = "" end
  else
    path = api.nvim_buf_get_name(buf) -- trash / ssh: the buffer name
  end
  if path == "" then return "%#BarProject# \u{f024b} " .. escape(project) .. " %#BarProjectArrowEnd#\u{e0b0}" end
  return "%#BarProject# \u{f024b} " .. escape(project) .. " %#BarProjectArrow#\u{e0b0}%<%#BarPath# " .. escape(path) .. " %#BarPathArrow#\u{e0b0}"
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
  api.nvim_create_autocmd("ColorScheme", { group = group, callback = function() vim.schedule(colors) end }) -- after the theme hooks set Comment
  api.nvim_create_autocmd("ModeChanged", { group = group, callback = function() M.project_colors(); vim.cmd("redrawstatus") end })
  api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufFilePost", "FileType" }, {
    group = group, callback = function() M.install() end,
  })
  -- the path, dot and counts follow the buffer: redraw when it is edited or saved, when git signs update and when the
  -- harpoon list changes (those two already redraw the status area; BufModifiedSet is the new one)
  api.nvim_create_autocmd({ "BufModifiedSet", "DiagnosticChanged" }, { group = group, callback = function() vim.cmd.redrawstatus() end })
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
