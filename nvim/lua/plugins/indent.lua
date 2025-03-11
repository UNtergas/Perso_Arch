
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    enable = not vim.g.vscode,
    config = function()
      require("ibl").setup({
        -- indent = {char = "|" },
        whitespace = {
            remove_blankline_trail = false,
        },
      })

      -- Set indent width to 2 spaces
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.list = true

    end,
  },
}

