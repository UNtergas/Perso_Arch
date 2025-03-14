return{
  {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = false,
  enabled = false,
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config= function ()
    require("neo-tree").setup({
        source_selector = {
          winbar = true,
        },
        sources = { "filesystem", "buffers", "git_status" },
        window = {
          auto_expand_width = false, -- 🔄 Disable auto-expanding width
        },
      })
  end
  }
}
