return{
  {
  "sunjon/shade.nvim",
  lazy = true,
  enabled = false,
  config = function()
    require("shade").setup({
      overlay_opacity = 85, -- Adjust the dimming effect
      opacity_step = 1,
      keys = { toggle = "<leader>st" }, -- Toggle with <leader>sh
    })
  end,
  }
}
