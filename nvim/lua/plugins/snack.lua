return{
  {
    "folke/snacks.nvim",
    priority = 1000,
    enabled = not vim.g.vscode,
    lazy = false,
    opts = {
      indent = {
        enable= true,
        size =2,
        use_tabs = true,
      },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      words = { enabled = true },
      dashboard = {
        preset = {
        header =[[
        ⠀⠀⠀⠀⠀⠀⣀⠄⠀⠠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠎⠀⠀⠀⢀⡴⠋⠉⢢⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠃⠠⠊⠰⣲⣾⡀⠀⢀⡜⠉⠉⠒⢤⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⠀⢇⠀⡠⠀⠰⠉⠉⠉⠀⠀⠀⠀⠀⢡⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢄⠀⠀⠀⢠⠁⠀⠀⠀⠀⠀⠀⠀⠀⣼⢑
⣤⣤⣤⣤⣤⣤⣤⡀⠀⠀⠀⠀⠀⠑⠀⡀⢀⢀⢤⠤⠤⠤⠤⠤⠐⠈⠉⠁
⣴⣿⡿⢿⣿⣿⣿⣿⣿⣶⣶⣦⣤⣶⣶⡾⠿⡿⠁⡀⠤⡀⠀⠀⠀⠀⠀⠀
⠀⠡⠶⠟⠋⠛⠛⠛⠛⠛⠛⠉⠉⠀⣼⠀⠀⠚⠚⠃⠐⢣⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⠇⠠⢊⣑⡦⣂⡀⠇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠊⠁⠀⠃⠀⠤⡟⡃⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠒⣾⠀⠈⠑⠃⠀⠀⣧⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠒⠒⠒⠒⠚⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ]],
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>n", function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
  }
}

