return{
  {
  "folke/trouble.nvim",
  opts = {
    modes={
      symbols={
        win = {
          size =0.3,
        }
      }
    },
  }, -- for default options, refer to the configuration section for custom setup.
  cmd = "Trouble",
  keys = {
    {
      "<leader>dd",
      "<cmd>Trouble diagnostics toggle focus=true<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>dD",
      "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=true<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=true win.position=bottom win.size=0.35<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>dL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>dQ",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
}
}

