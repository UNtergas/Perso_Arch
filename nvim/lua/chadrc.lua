-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedark",
  changed_themes = {
      onedark = {
         base_00 = "#303030"
      },
   },
	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }
M.ui = {
      tabufline = {
         lazyload = false
      },
      statusline = {
          theme = "vscode_colored",
          separator_style = "block",
          order = nil,
          modules = nil,
      },
}

M.nvdash = {
    load_on_startup = true,

    header = {
      "                                                ",
      "                                          _.oo. ",
      "                  _.u[[/;:,.         .odMMMMMM' ",
      "               .o888UU[[[/;:-.  .o@P^    MMM^   ",
      "              oN88888UU[[[/;::-.        dP^     ",
      "             dNMMNN888UU[[[/;:--.   .o@P^       ",
      "            ,MMMMMMN888UU[[/;::-. o@^           ",
      "            NNMMMNN888UU[[[/~.o@P^              ",
      "            888888888UU[[[/o@^-..               ",
      "           oI8888UU[[[/o@P^:--..                ",
      "        .@^  YUU[[[/o@^;::---..                 ",
      "      oMP     ^/o@P^;:::---..                   ",
      "   .dMMM    .o@^ ^;::---...                     ",
      "  dMMMMMMM@^`       `^^^^                       ",
      " YMMMUP^                                        ",
      "  ^^                                            ",
      "                                                ",
    },


     buttons = {
       { txt = "  Find File", keys = "Spc f f", cmd = "Telescope find_files" },
       { txt = "  Recent Files", keys = "Spc f o", cmd = "Telescope oldfiles" },
       -- more... check nvconfig.lua file for full list of buttons
     },
   }
return M
