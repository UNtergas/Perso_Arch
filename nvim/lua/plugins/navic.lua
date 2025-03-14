return{
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    config = function()
      local navic = require("nvim-navic")
      navic.setup {
        highlight = true,
        separator = " > ",
        depth_limit = 3,
      }

      -- Set winbar globally
      vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
    end
  }
}
