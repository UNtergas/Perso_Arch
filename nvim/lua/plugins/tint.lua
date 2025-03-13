return {
  -- Add tint.nvim
  {
    "levouh/tint.nvim",
    event = "VeryLazy", -- Load when UI is ready
    config = function()
      require("tint").setup({
        tint = -5, -- Adjust darkness of inactive splits
        saturation = 0.6, -- Keep colors slightly desaturated
        highlight_ignore_patterns = { "WinSeparator", "Status.*", "NeoTree.*" }, -- Ignore certain UI elements
        window_ignore_function = function(winid)
          local buf = vim.api.nvim_win_get_buf(winid)
          local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
          return buftype == "terminal" or buftype == "nofile"
        end
      })
    end
  }
}

