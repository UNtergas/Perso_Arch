vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false, -- Ensure LSP loads immediately
  },
  { "nvzone/menu" , enabled= false, },
  {
    "nvchad/base46",
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
    end,
  },
  { import = "plugins" },
}, lazy_config)


-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

-- vim.cmd [[
--   highlight NeoTreeNormal guibg=#181b21
--   highlight NeoTreeNormalNC guibg=#181b21
--   highlight NeoTreeEndOfBuffer guibg=#181b21 guifg=#181b21
-- ]]


      -- Set winbar globally
vim.schedule(function()
  require "mappings"
end)
