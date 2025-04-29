return{
  {
  "gelguy/wilder.nvim",
  enabled = not vim.g.vscode,
  event = "CmdlineEnter",
  dependencies = { "romgrk/fzy-lua-native" },
  config = function()
    vim.cmd([[
      call wilder#setup({'modes': [':', '/', '?']})
      call wilder#set_option('renderer', wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
        \ 'highlighter': wilder#basic_highlighter(),
        \ 'border': 'rounded',
        \ 'left': [' ', wilder#popupmenu_devicons()],
        \ 'right': [' ', wilder#popupmenu_scrollbar()],
        \ })))
    ]])
  end
  }
}

