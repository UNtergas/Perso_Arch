return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
    ensure_installed = {
        "lua", "javascript", "typescript", "python", "go", "rust",
        "bash", "json", "yaml", "html", "css", "scss", "tsx", "c", "cpp"
        }, -- Add more languages as needed
  	},
  },
}
