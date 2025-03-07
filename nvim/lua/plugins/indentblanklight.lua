return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
        -- Character for tab-based indentation
          highlight = "IndentBlanklineChar",
        },
        whitespace = {
          remove_blankline_trail = false, -- Keeps spacing consistent
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
          injected_languages= false,
          shighlight = { "Function", "Label" },
        },
        show_current_context = true,
        show_current_context_start = true,
      })
      -- Set indent width to 2 spaces
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.list = true

      -- Ensure indentation highlight is visible
      vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#555555" })
      vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#d4be98"})
    end,
  }
}

