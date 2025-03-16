
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        source_selector = {
          winbar = true,
        },
        sources = { "filesystem", "buffers", "git_status" },
        window = {
          auto_expand_width = false, -- 🔄 Disable auto-expanding width
        },
        filesystem = {
          bind_to_cwd = true,           -- 🗂 Keep bound to current working directory
          follow_current_file = {
            enabled = false,           -- 🚫 Don't auto-focus opened file in tree
          },
          hijack_netrw_behavior = "open_default", -- 📂 Optional: open in place of netrw
          use_libuv_file_watcher = true,
        },
        event_handlers = {
          {
            event = "file_opened",
            handler = function(file_path)
              -- 🚫 Prevent auto-closing or auto-collapsing when a file is opened
              -- Do nothing on purpose
            end,
          },
        },
      })
    end,
  }
}
