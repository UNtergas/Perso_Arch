
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },  -- Change to your preferred indent character
        scope = {
          enabled = true,   -- Enable block highlighting
          show_start = true,  -- Show start of the current block
          show_end = false,  -- Hide end of block
        },
      })
    end,
  }
}
