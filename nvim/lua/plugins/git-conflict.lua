return{
  {
    "akinsho/git-conflict.nvim",
    enabled = not vim.g.vscode,
    lazy = false,
    version = "*",
    config = function()
      require("git-conflict").setup({
        {
          default_mappings = true, -- disable buffer local mapping created by this plugin
          default_commands = true, -- disable commands created by this plugin
          disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
          list_opener = 'copen', -- command or function to open the conflicts list
          highlights = { -- They must have background color, otherwise the default color will be used
            incoming = 'DiffAdd',
            current  = 'DiffText',
          },
        }
      })

      -- Define custom highlight groups for Gruvbox Material Dark
      vim.api.nvim_set_hl(0, 'DiffText', { fg = "#ffffff", bg = "#1d3b40" })
      vim.api.nvim_set_hl(0, 'DiffAdd', { fg = "#ffffff", bg = "#1d3450" })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'GitConflictDetected',
        callback = function()
          vim.notify('Conflict detected in file '..vim.api.nvim_buf_get_name(0))
          vim.cmd('LspStop')
        end
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'GitConflictResolved',
        callback = function()
          vim.cmd('LspRestart')
        end
      })

    end,
  }
}





