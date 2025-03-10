
  return {
    {
      "lukas-reineke/indent-blankline.nvim",
      enabled = false,
      main = "ibl",
      config = function()
        require("ibl").setup({
          indent = {
            char = "│", -- Change to your preferred indent character
            highlight = "IndeBlanklineChar",  -- This cause error, but this will make vscode work
          },
          whitespace = {
            remove_blankline_trail = false, -- Keeps spacing consistent
          },
          scope = {
            enabled = true,   -- Enable block highlighting
            show_start = true,  -- Show start of the current block
            show_end = false,  -- Hide end of block
            injected_languages = false,
            highlight = { "Function", "Label" },
          },
        })

        -- Set indent width to 2 spaces
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.list = true

        -- Ensure indentation highlight is visible
        vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#555555" })
        vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = "#d4be98" })
      end,
    },
  }

