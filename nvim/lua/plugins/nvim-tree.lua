return {
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    enabled = true,
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- Optional but recommended
    },
    config = function()
      require("nvim-tree").setup({
        hijack_cursor = true,
        sync_root_with_cwd = true,
        view = {
          adaptive_size = false,
        },
        renderer = {
          full_name = true,
          group_empty = true,
          special_files = {},
          symlink_destination = false,
          indent_markers = {
            enable = true,
          },
          icons = {
            git_placement = "signcolumn",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        update_focused_file = {
          enable = true,
          update_root = true,
          ignore_list = { "help" },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = false,
        },
        filters = {
          custom = {
            "^.git$",
          },
        },
        actions = {
          change_dir = {
            enable = false,
            restrict_above_cwd = true,
          },
          open_file = {
            resize_window = true,
            window_picker = {
              chars = "aoeui",
            },
          },
          remove_file = {
            close_window = false,
          },
        },
        log = {
          enable = false,
          truncate = true,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
          },
        },
      })
    end,
  }
}
