return {
  "simrat39/symbols-outline.nvim",
  config = function()
    require("symbols-outline").setup({
      highlight_hovered_item = true,
      show_guides = true,
      auto_oreview = false,
      position = "right",
      width = 30,
      show_numbers = false,
      show_relative_numbers = false,
      show_symbol_details = true,
      keymaps = {
        close = { "q","<Esc>" },
        goto_location = "<CR>",
        focus_location = "o",
        hover_symbol = "<C-space>",
        rename_symbol = "r",
        code_actions = "a",
      },
    })

  end,
  cmd = "SymbolsOutline",
}
