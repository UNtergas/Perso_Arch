-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "doomchad",

  -- changed_themes = {
  --     onedark = {
  --        base_16 = { base00 = "#202020" },
  --     },
  --     doomchad = {
  --        base_16 = { base00 = "#202020" },
  --     },
  --  },
	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.ui = {
      tabufline = {
         lazyload = false
      },
      statusline = {
          theme = "default",
          separator_style = "arrow",
      },
}
-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}
M.colorify ={
  enabled = not vim.g.vscode,
}

M.lsp = {
   signature = false,
}
return M
