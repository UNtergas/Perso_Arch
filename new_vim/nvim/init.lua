vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes:1"
vim.opt.updatetime = 25
vim.opt.clipboard = "unnamedplus"

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Wrapping (Emacs: soft word wrap)
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.undofile = true

-- Folding: treesitter folds, arrow in the gutter on the line a fold starts
-- (a custom statuscolumn, because the built-in fold column prints depth digits)
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "" -- show the folded line itself, highlighted
vim.opt.fillchars = { fold = " ", eob = " " }

function _G.fold_icon()
  if vim.v.virtnum ~= 0 then return " " end
  local l = vim.v.lnum
  if vim.fn.foldclosed(l) == l then return "\u{f054}" end -- closed: chevron right
  local lvl = vim.fn.foldlevel(l)
  if lvl > 0 and lvl > vim.fn.foldlevel(l - 1) then return "\u{f078}" end -- open fold starts here
  return " "
end
function _G.fold_click()
  local m = vim.fn.getmousepos()
  vim.api.nvim_win_set_cursor(0, { m.line, 0 })
  pcall(vim.cmd, "normal! za")
end
vim.opt.statuscolumn = "%@v:lua.fold_click@%{v:lua.fold_icon()}%X %s%=%l "

-- keep the cursor a few lines from the edge: the sticky function header
-- (treesitter-context) needs room above the cursor to show
vim.opt.scrolloff = 5

-- Light theme
vim.opt.background = "light"
vim.g.health = { style = "float" } -- :checkhealth in a float, not a new tab (one tab per nvim)
-- the float's own q deletes the buffer and leaves an empty float behind; close the window instead
vim.api.nvim_create_autocmd("FileType", {
  pattern = "checkhealth",
  callback = function(ev) vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, nowait = true }) end,
})

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Theme (Alabaster, same as the Emacs config)
  {
    "dchinmay2/alabaster.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "light"
      local function tweak()
        local hl = vim.api.nvim_set_hl
        -- slightly grey background (Alabaster's own is near white)
        local bg, float, line = "#f5f5f5", "#ededed", "#ebebeb"
        hl(0, "Normal", { fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg, bg = bg })
        hl(0, "NormalNC", { bg = bg })
        hl(0, "NormalFloat", { bg = float })
        hl(0, "SignColumn", { bg = bg })
        hl(0, "FoldColumn", { fg = "#8a8a8a", bg = bg })
        hl(0, "LineNr", { fg = "#8a8a8a", bg = bg })
        hl(0, "EndOfBuffer", { fg = bg, bg = bg })
        hl(0, "CursorLine", { bg = line })
        -- VS Code Chalice: standard-library classes/types (Promise, Set, Map...) are blue too
        for _, k in ipairs({ "class", "interface", "type", "enum" }) do
          hl(0, "@lsp.typemod." .. k .. ".defaultLibrary", { fg = "#325cc0" })
        end
        -- LSP sets a black fg on these tokens, which hides the treesitter blue: make all type names blue
        for _, k in ipairs({ "class", "interface", "type", "enum" }) do
          hl(0, "@lsp.type." .. k, { fg = "#325cc0" })
          hl(0, "@lsp.typemod." .. k .. ".declaration", { fg = "#325cc0" }) -- beats @lsp.mod.declaration (black)
        end
        -- type parameters: blue where declared (<P extends X>), black where used
        hl(0, "@lsp.type.typeParameter", { fg = "#000000" })
        hl(0, "@lsp.typemod.typeParameter.declaration", { fg = "#325cc0" })
        -- flash: grey out all text, red on the letters being jumped to
        hl(0, "FlashBackdrop", { fg = "#b4b4b4" })
        hl(0, "FlashLabel", { fg = "#ffffff", bg = "#d32f2f", bold = true })
        hl(0, "FlashMatch", { fg = "#d32f2f", bold = true })
        hl(0, "FlashCurrent", { fg = "#d32f2f", bold = true, underline = true })
        hl(0, "Folded", { fg = "#6a6a6a", bg = "#e4e4e4" })
        -- diagnostic marks: red = error, yellow = warning
        hl(0, "DiagnosticSignError", { fg = "#d32f2f", bold = true })
        hl(0, "DiagnosticSignWarn", { fg = "#e6a700", bold = true })
        hl(0, "DiagnosticSignInfo", { fg = "#1e88e5" })
      end
      vim.api.nvim_create_autocmd("ColorScheme", { pattern = "alabaster", callback = tweak })
      -- Chalice/Alabaster in VS Code: only entity.name is blue (function-valued keys, calls, types); `string` etc. stay black
      local blue_rules = {
        "(pair key: (property_identifier) @AlabasterDefinition value: [(arrow_function) (function_expression)] (#set! priority 130))",
        "(call_expression function: (identifier) @AlabasterDefinition (#set! priority 130))",
        "(call_expression function: (member_expression property: (property_identifier) @AlabasterDefinition (#set! priority 130)))",
        "(type_identifier) @AlabasterDefinition (#set! priority 130)", -- TS only
        "(new_expression constructor: (identifier) @AlabasterDefinition (#set! priority 130))",
        "(method_definition name: (property_identifier) @AlabasterDefinition (#set! priority 130))",
        "(function_declaration name: (identifier) @AlabasterDefinition (#set! priority 130))",
      }
      for _, lang in ipairs({ "typescript", "tsx", "javascript" }) do
        -- keep only the rules this grammar understands (e.g. JavaScript has no type_identifier)
        local ok_rules = {}
        for _, rule in ipairs(blue_rules) do
          if pcall(vim.treesitter.query.parse, lang, rule) then table.insert(ok_rules, rule) end
        end
        pcall(vim.treesitter.query.set, lang, "highlights", "; extends\n" .. table.concat(ok_rules, "\n"))
      end
      -- treesitter highlighting is not on by default; the blue rules above need it (TS/JS only)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
      })
      vim.cmd.colorscheme("alabaster")
      tweak()
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- rewrite: needs nvim 0.12+ and tree-sitter-cli 0.26.1+ (cargo install tree-sitter-cli --locked)
    lazy = false, -- main does not support lazy-loading
    enabled = not vim.g.vscode,
    build = ":TSUpdate",

    config = function()
      -- no-op for parsers already installed; runs async
      require("nvim-treesitter").install({
        "lua",
        "c",
        "cpp",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "java",
        "rust",
        "json",
        "html",
        "css",
        "bash",
        "dockerfile",
        "fish",
        "go",
        "graphql",
        "luadoc",
        "markdown",
        "markdown_inline",
        "php",
        "printf",
        "scss",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      })
    end,
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "1.*",
    enabled = not vim.g.vscode,

    opts = {
	keymap = {
	  preset = "default",

	  ["<C-j>"] = {
	    "select_next",
	    "fallback",
	  },

	  ["<C-k>"] = {
	    "select_prev",
	    "fallback",
	  },

	  ["<CR>"] = {
	    "accept",
	    "fallback",
	  },
	},

      completion = {
        menu = {
          auto_show = true,
        },
      },

      cmdline = {
        enabled = true,

        completion = {
          menu = {
            auto_show = true,
          },
        },
      },
    },
  },

  -- Mason
  {
    "mason-org/mason.nvim",
    enabled = not vim.g.vscode,

    opts = {},
  },

  -- Mason LSP
  {
    "mason-org/mason-lspconfig.nvim",
    enabled = not vim.g.vscode,

    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },

    opts = {
      ensure_installed = {
        "clangd",
        "ts_ls",
        "pyright",
        "jdtls",
        "rust_analyzer",
      },

      automatic_enable = true,
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    enabled = not vim.g.vscode,

    dependencies = {
      "saghen/blink.cmp",
    },

    config = function()
      local capabilities =
        require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- tsserver: less background work (same idea as the Emacs config)
      vim.lsp.config("ts_ls", {
        init_options = {
          disableAutomaticTypingAcquisition = true,
          maxTsServerMemory = 3072,
        },
      })

      -- drop Neovim's default gr* maps so plain `gr` has no timeout delay
      for _, lhs in ipairs({ "grr", "gra", "grn", "gri", "grt", "grx" }) do
        pcall(vim.keymap.del, "n", lhs)
        pcall(vim.keymap.del, "x", lhs)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local o = { buffer = event.buf, silent = true }
          local function m(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, vim.tbl_extend("force", o, { desc = desc }))
          end
          m("gd", vim.lsp.buf.definition, "Go to definition")
          m("gD", vim.lsp.buf.declaration, "Go to declaration")
          m("gr", function() require("trouble").open({ mode = "lsp_references", focus = true }) end, "Show references")
          m("gi", vim.lsp.buf.implementation, "Go to implementation")
          m("K", vim.lsp.buf.hover, "Hover docs")
          m("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          m("<leader>ca", function() _G.code_action() end, "Code action", { "n", "v" })
          m("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          m("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
        end,
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          severity = { min = vim.diagnostic.severity.WARN }, -- errors and warnings only
          numhl = { -- color the line number instead of using a second sign column
            [vim.diagnostic.severity.ERROR] = "DiagnosticError",
            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    enabled = not vim.g.vscode,

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    keys = {
      {
        "<leader>ff",
        "<cmd>Telescope find_files<cr>",
        desc = "Find files",
      },

      {
        "<leader>fg",
        "<cmd>Telescope live_grep<cr>",
        desc = "Find text",
      },

      {
        "<leader>fb",
        "<cmd>Telescope buffers<cr>",
        desc = "Find buffers",
      },

      {
        "<leader>fr",
        "<cmd>Telescope oldfiles<cr>",
        desc = "Recent files",
      },

      {
        "<leader>fh",
        "<cmd>Telescope help_tags<cr>",
        desc = "Help",
      },
    },

    -- one tab per nvim: no "open in new tab" from a picker
    opts = {
      defaults = {
        -- flex: narrow windows stack the preview above the results instead of dropping it
        layout_strategy = "flex",
        layout_config = { width = 0.95, height = 0.95 },
        path_display = { "truncate" },
        -- C-g: show the results in Trouble, grouped by file (C-q still fills the quickfix list)
        mappings = {
          i = {
            ["<C-t>"] = false,
            ["<C-g>"] = function(...) return require("trouble.sources.telescope").open(...) end,
          },
          n = {
            ["<C-t>"] = false,
            ["<C-g>"] = function(...) return require("trouble.sources.telescope").open(...) end,
          },
        },
      },
    },
  },

  -- Trouble: results listed under one header per file
  {
    "folke/trouble.nvim",
    enabled = not vim.g.vscode,
    cmd = "Trouble",
    opts = {
      focus = true,
      win = { position = "bottom", size = 0.5 },
    },
  },

  -- Dropbar: winbar with only the symbol breadcrumb of the current file (class > method).
  -- The file path is in the tabline row above.
  {
    "Bekaboo/dropbar.nvim",
    enabled = not vim.g.vscode,
    event = "VeryLazy",
    opts = {
      bar = {
        -- the default sources minus `path`
        sources = function(buf)
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")
          if vim.bo[buf].ft == "markdown" then return { sources.markdown } end
          if vim.bo[buf].buftype == "terminal" then return { sources.terminal } end
          return { utils.source.fallback({ sources.lsp, sources.treesitter }) }
        end,
        -- every real file gets the bar (the default only shows it for treesitter / LSP buffers)
        enable = function(buf, win)
          return vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_win_is_valid(win)
            and vim.fn.win_gettype(win) == ""
            and vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf) ~= ""
            and vim.bo[buf].filetype ~= "oil"
            and vim.wo[win].winbar == ""
        end,
      },
    },
  },

  -- grug-far: project search and replace, live results under one header per file
  {
    "MagicDuck/grug-far.nvim",
    enabled = not vim.g.vscode,
    cmd = "GrugFar",
    opts = {
      headerMaxWidth = 80,
      keymaps = { replace = false }, -- sync only: Replace ignores what's in the results list
    },
    config = function(_, opts)
      require("grug-far").setup(opts)
      -- header shows Help and the sync actions; the other keys still work (g? lists them)
      local help = require("grug-far.render.help")
      local render = help.getHelpVirtLines
      help.getHelpVirtLines = function(context, actions)
        if actions ~= context.actions then return render(context, actions) end -- history window has its own
        return render(context, vim.tbl_filter(function(a)
          return a.text == "Help" or a.text:find("^Sync") ~= nil
        end, actions))
      end
    end,
    keys = {
      { "<leader>sr", function() require("grug-far").open({ transient = true }) end, mode = { "n", "v" }, desc = "Search and replace (grouped by file)" },
    },
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = not vim.g.vscode,
    lazy = true,
  },

  -- Flash
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},

    keys = {
      {
        "s",
        mode = { "n", "x", "o" },

        function()
          require("flash").jump()
        end,

        desc = "Flash",
      },

      {
        "S",
        mode = { "n", "x", "o" },

        function()
          require("flash").treesitter()
        end,

        desc = "Flash Treesitter",
      },

      {
        "r",
        mode = "o",

        function()
          require("flash").remote()
        end,

        desc = "Remote Flash",
      },

      {
        "R",
        mode = { "o", "x" },

        function()
          require("flash").treesitter_search()
        end,

        desc = "Treesitter Search",
      },

      {
        "<C-\\>",
        mode = "c",

        function()
          require("flash").toggle()
        end,

        desc = "Toggle Flash Search",
      },
    },
  },

  -- Harpoon: a short per-project list of files to jump between
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = (function()
      local function h() return require("harpoon") end
      local keys = {
        { "<leader>ha", function() h():list():add(); vim.cmd.redrawstatus() end, desc = "Harpoon: add file" },
        { "<leader>hd", function() h():list():remove(); vim.cmd.redrawstatus() end, desc = "Harpoon: remove current file" },
        { "<leader>hh", function() h().ui:toggle_quick_menu(h():list()) end, desc = "Harpoon: list" },
      }
      for i = 1, 4 do
        table.insert(keys, { "<leader>" .. i, function() h():list():select(i) end, desc = "Harpoon: file " .. i })
      end
      return keys
    end)(),
    config = function()
      require("harpoon"):setup()
      -- refresh the statusline when the list is edited in the menu
      require("harpoon"):extend({ LIST_CHANGE = function() vim.cmd.redrawstatus() end })
    end,
  },

  -- Indent guides: one colour per indent level
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = not vim.g.vscode,
    main = "ibl",
    config = function()
      local ibl = require("ibl")
      local hooks = require("ibl.hooks")
      local names = { "IblL1", "IblL2", "IblL3", "IblL4", "IblL5", "IblL6" }
      local colors = { "#d98a8a", "#d9b25f", "#7fae6f", "#5fa8b8", "#7d95d6", "#b58ad6" }
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        for k, name in ipairs(names) do
          vim.api.nvim_set_hl(0, name, { fg = colors[k] })
        end
      end)
      ibl.setup({
        indent = { char = "│", highlight = names },
        scope = { enabled = false }, -- scope line would hide the per-level colours
      })
    end,
  },


  ---------------------------------------------------------------------------
  -- Emacs-parity plugins
  ---------------------------------------------------------------------------
  { -- bufdelete + rename with LSP import updates, and the start screen (just a cat)
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      picker = { enabled = true }, -- also replaces vim.ui.select (code actions, etc.) with a filterable list
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            [[  /\_/\  ]],
            [[ ( o.o ) ]],
            [[  > ^ <  ]],
            [[ /|   |\ ]],
            [[(_|   |_)]],
          }, "\n"),
          keys = {
            {
              icon = "\u{f07b} ",
              key = "p",
              desc = "Open old project",
              action = function()
                -- pick a recent project, cd into it, browse it in Oil
                Snacks.picker.projects({
                  confirm = function(picker, item)
                    picker:close()
                    if not item then return end
                    vim.cmd.cd(vim.fn.fnameescape(item.file))
                    require("oil").open(item.file)
                  end,
                  win = { input = { keys = { ["<c-t>"] = false } } }, -- one tab per nvim
                })
              end,
            },
            { icon = "\u{f07c} ", key = "e", desc = "File explorer", action = function() require("oil").open(vim.fn.getcwd()) end },
            { icon = "\u{f15b} ", key = "n", desc = "Empty buffer", action = ":enew" },
            { icon = "\u{f1e6} ", key = "l", desc = "Update plugins (Lazy, then U)", action = ":Lazy" },
            { icon = "\u{f0ad} ", key = "m", desc = "Mason (LSP servers and tools)", action = ":Mason" },
            { icon = "\u{f0f1} ", key = "h", desc = "Plugin health check", action = ":checkhealth lazy" },
            { icon = "\u{f085} ", key = "s", desc = "LSP health check", action = ":checkhealth vim.lsp" },
            { icon = "\u{f011} ", key = "q", desc = "Exit", action = ":qa" },
          },
        },
        sections = { { section = "header" }, { section = "keys", gap = 1, padding = 1 } },
      },
    },
  },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "lewis6991/gitsigns.nvim", event = "VeryLazy", opts = { sign_priority = 20 } }, -- above diagnostics so git marks always show
  { -- colors conflict blocks (ours / theirs) in the file
    "akinsho/git-conflict.nvim",
    event = "BufReadPost",
    config = function()
      require("git-conflict").setup({ default_mappings = false, disable_diagnostics = false })
      -- ours = light green, theirs = light blue (set after the plugin so ours wins on colorscheme change)
      local function conflict_colors()
        vim.api.nvim_set_hl(0, "GitConflictCurrent", { bg = "#c9efc9" })
        vim.api.nvim_set_hl(0, "GitConflictCurrentLabel", { bg = "#9fdc9f", bold = true })
        vim.api.nvim_set_hl(0, "GitConflictIncoming", { bg = "#cfe5fa" })
        vim.api.nvim_set_hl(0, "GitConflictIncomingLabel", { bg = "#9cc8f0", bold = true })
        vim.api.nvim_set_hl(0, "GitConflictAncestor", { bg = "#eeeeee" })
        vim.api.nvim_set_hl(0, "GitConflictAncestorLabel", { bg = "#d4d4d4", bold = true })
      end
      conflict_colors()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = conflict_colors })
    end,
  },
  { -- 3-way merge tool: ours | merged (edit here) | theirs
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local function merge_colors()
        local hl = vim.api.nvim_set_hl
        hl(0, "MergeOurs", { bg = "#c9efc9" })
        hl(0, "MergeOursText", { bg = "#9fdc9f" })
        hl(0, "MergeTheirs", { bg = "#cfe5fa" })
        hl(0, "MergeTheirsText", { bg = "#9cc8f0" })
        -- middle window: no diff background, so only the conflict colors show there
        hl(0, "MergeLocal", { bg = "NONE" })
        hl(0, "MergeLocalText", { bg = "NONE" })
        hl(0, "MergeFiller", { fg = "#cccccc", bg = "#f7f7f7" })
      end
      merge_colors()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = merge_colors })
      -- diff3_horizontal: a = ours (left), b = merged file (middle), c = theirs (right)
      local winhl = {
        a = "DiffAdd:MergeOurs,DiffChange:MergeOurs,DiffText:MergeOursText,DiffDelete:MergeFiller",
        b = "DiffAdd:MergeLocal,DiffChange:MergeLocal,DiffText:MergeLocalText,DiffDelete:MergeFiller",
        c = "DiffAdd:MergeTheirs,DiffChange:MergeTheirs,DiffText:MergeTheirsText,DiffDelete:MergeFiller",
      }
      require("diffview").setup({
        view = { merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true } },
        hooks = {
          diff_buf_win_enter = function(_, winid, ctx)
            if winhl[ctx.symbol] and ctx.layout_name:match("^diff3") then
              vim.wo[winid].winhighlight = winhl[ctx.symbol]
            end
          end,
        },
      })
    end,
  },
  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },
  { "nvim-treesitter/nvim-treesitter-context", event = "BufReadPost", opts = { max_lines = 3 } },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_visual_mappings = true -- `S` in visual is flash treesitter
    end,
    config = function()
      vim.keymap.set("x", "gs", "<Plug>(nvim-surround-visual)", { desc = "Surround selection" })
    end,
  },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    opts = { formatters_by_ft = { python = { "black" }, rust = { "rustfmt" } } },
  },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      -- like VS Code: first press selects the word under the cursor, then each press adds the next match
      vim.keymap.set("n", "<C-d>", function()
        vim.cmd("normal! viw")
        mc.matchAddCursor(1)
      end, { desc = "Select word, add next match cursor" })
      vim.keymap.set("x", "<C-d>", function() mc.matchAddCursor(1) end, { desc = "Add next match cursor" })
      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<esc>", function()
          if not mc.cursorsEnabled() then mc.enableCursors() else mc.clearCursors() end
        end)
      end)
    end,
  },
  -- Oil
  {
    "stevearc/oil.nvim",
    enabled = not vim.g.vscode,
    lazy = false, -- load at startup so `nvim .` / `:e .` open Oil instead of netrw

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    keys = {
      {
        "<leader>e",
        "<cmd>Oil<cr>",
        desc = "File browser",
      },
    },

    opts = {
      default_file_explorer = true,
      delete_to_trash = true, -- restore: g\ shows the trash, dd the file, go to the folder, p, :w

      -- one tab per nvim: no "open in new tab", no tab-local :tcd
      keymaps = {
        ["<C-t>"] = false,
        ["g~"] = false,
      },

      view_options = {
        show_hidden = true,
      },
    },
  },
})

-------------------------------------------------------------------------------
-- Keymaps (ported from the Doom Emacs config, see emacs_config/KEY_GUIDE.md)
-------------------------------------------------------------------------------
local map = vim.keymap.set
local function tb(fn, opts)
  return function() require("telescope.builtin")[fn](opts) end
end

-- ctrl+s save, ctrl+f search in buffer, esc clears highlight
map({ "n", "v", "i" }, "<C-s>", "<cmd>write<cr>", { desc = "Save" })
map({ "n", "v" }, "<C-f>", "/", { desc = "Search in buffer" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear highlight" })

-- alt+p / alt+o: indent / outdent
map("n", "<M-p>", ">>", { desc = "Indent" })
map("n", "<M-o>", "<<", { desc = "Outdent" })
map("i", "<M-p>", "<C-t>", { desc = "Indent" })
map("i", "<M-o>", "<C-d>", { desc = "Outdent" })
map("v", "<M-p>", ">gv", { desc = "Indent" })
map("v", "<M-o>", "<gv", { desc = "Outdent" })

-- ctrl+n toggles Oil: opens at the current file's folder, again goes back to where you were
map({ "n", "v" }, "<C-n>", function()
  if vim.bo.filetype ~= "oil" then return require("oil").open() end
  if vim.bo.modified then return vim.notify("Oil has unsaved changes: :w to apply, u to undo", vim.log.levels.WARN) end
  require("oil").close()
end, { desc = "Toggle Oil" })
map({ "n", "v" }, "<C-b>", tb("buffers"), { desc = "Switch buffer" })

-- diagnostics / hunks: ]d [d ]g [g
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]g", function() require("gitsigns").nav_hunk("next") end, { desc = "Next hunk" })
map("n", "[g", function() require("gitsigns").nav_hunk("prev") end, { desc = "Prev hunk" })

-- ctrl+alt+arrows: focus window
for key, dir in pairs({ Left = "h", Down = "j", Up = "k", Right = "l" }) do
  map("n", "<C-M-" .. key .. ">", "<C-w>" .. dir, { desc = "Focus window " .. dir })
end

-- ctrl+w q / ctrl+w ctrl+w: close buffer, ctrl+w a: close all buffers
map("n", "<C-w>q", function() Snacks.bufdelete() end, { desc = "Close buffer" })
map("n", "<C-w><C-w>", function() Snacks.bufdelete() end, { desc = "Close buffer" })
map("n", "<C-w>a", function() Snacks.bufdelete.all() end, { desc = "Close all buffers" })
map("n", "<C-w>T", "<Nop>", { desc = "Disabled: one tab per nvim" })
-- ; is : (this also makes flash leave ; alone in every mode); f/t repeat: press f/t again, , goes back
map({ "n", "x" }, ";", ":", { desc = "Command line" })

-- ctrl+k chords
local function mk_parent(p)
  local dir = vim.fn.fnamemodify(p, ":h")
  if dir ~= "" and dir ~= "." then vim.fn.mkdir(dir, "p") end
end
local ck = { "n", "v" }
map(ck, "<C-k><Left>", "<cmd>leftabove vsplit<cr>", { desc = "Split left" })
map(ck, "<C-k><Right>", "<cmd>rightbelow vsplit<cr>", { desc = "Split right" })
map(ck, "<C-k><Up>", "<cmd>leftabove split<cr>", { desc = "Split up" })
map(ck, "<C-k><Down>", "<cmd>rightbelow split<cr>", { desc = "Split down" })
map(ck, "<C-k>h", "<C-w>H", { desc = "Move window left" })
map(ck, "<C-k>j", "<C-w>J", { desc = "Move window down" })
map(ck, "<C-k>k", "<C-w>K", { desc = "Move window up" })
map(ck, "<C-k>l", "<C-w>L", { desc = "Move window right" })
map(ck, "<C-k>a", function()
  vim.ui.input({ prompt = "New file: ", completion = "file" }, function(p)
    if p and p ~= "" then mk_parent(p); vim.cmd("edit " .. vim.fn.fnameescape(p)) end
  end)
end, { desc = "New file" })
map(ck, "<C-k>A", function()
  vim.ui.input({ prompt = "New folder: ", completion = "dir" }, function(p)
    if p and p ~= "" then vim.fn.mkdir(p, "p") end
  end)
end, { desc = "New folder" })

-- leader (SPC) maps, Doom style
map("n", "<leader><leader>", tb("find_files"), { desc = "Find file in project" })
map("n", "<leader>.", tb("find_files", { hidden = true }), { desc = "Find any file" })
map("n", "<leader>,", tb("buffers"), { desc = "Switch buffer" })
map("n", "<leader>:", tb("commands"), { desc = "Command palette" })
map("n", "<leader>ss", tb("current_buffer_fuzzy_find"), { desc = "Search lines in buffer" })
map("n", "<leader>sp", tb("live_grep"), { desc = "Search project" })
map("n", "<leader>sw", function()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").live_grep({ default_text = "\\b" .. word .. "\\b", prompt_title = "Whole word: " .. word })
end, { desc = "Search word under cursor (whole word)" })
map("n", "<leader>su", "<cmd>UndotreeToggle<cr>", { desc = "Undo tree" })
map("n", "<leader>bb", tb("buffers"), { desc = "Switch buffer" })
map("n", "<leader>bS", "<cmd>wall<cr>", { desc = "Save all buffers" })
map("n", "<leader>fR", function() Snacks.rename.rename_file() end, { desc = "Rename file (updates imports)" })
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format (manual)" })
-- SPC c x: Trouble, diagnostics of every open file grouped under one header per file (again closes it).
-- SPC c X: the same diagnostics in a flat Telescope list.
map("n", "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (grouped by file)" })
map("n", "<leader>cX", tb("diagnostics"), { desc = "Diagnostics list (Telescope)" })
-- merge conflicts
map("n", "<leader>gm", "<cmd>DiffviewOpen<cr>", { desc = "Merge tool (3-way)" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close merge tool" })
map("n", "]x", "<cmd>GitConflictNextConflict<cr>", { desc = "Next conflict" })
map("n", "[x", "<cmd>GitConflictPrevConflict<cr>", { desc = "Prev conflict" })
map("n", "<leader>go", "<cmd>GitConflictChooseOurs<cr>", { desc = "Conflict: keep ours" })
map("n", "<leader>gt", "<cmd>GitConflictChooseTheirs<cr>", { desc = "Conflict: keep theirs" })
map("n", "<leader>gb", "<cmd>GitConflictChooseBoth<cr>", { desc = "Conflict: keep both" })
map("n", "<leader>g0", "<cmd>GitConflictChooseNone<cr>", { desc = "Conflict: keep none" })
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "Revert hunk" })

-- terminal: toggle a bottom terminal (keeps its shell alive when hidden)
local term = { buf = nil, win = nil }
local function toggle_term()
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    term.win = nil
    return
  end
  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, math.floor(vim.o.lines / 2))
  term.win = vim.api.nvim_get_current_win()
  if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
    vim.api.nvim_win_set_buf(term.win, term.buf)
  else
    vim.cmd("terminal")
    term.buf = vim.api.nvim_get_current_buf()
    vim.bo[term.buf].buflisted = false
  end
  vim.cmd("startinsert")
end
map("n", "<leader>ot", toggle_term, { desc = "Toggle terminal" })

-- Alt-q (or SPC q): close the popups (Trouble, quickfix, help, grug-far, floats, bottom terminal), keep the files
local popup_ft = { trouble = true, qf = true, help = true, checkhealth = true, ["grug-far"] = true, ["grug-far-history"] = true }
local function close_popups()
  if vim.fn.mode() == "t" then vim.cmd("stopinsert") end
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    pcall(vim.api.nvim_win_hide, term.win)
    term.win = nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- closing one popup can take others with it (Trouble closes its preview float), so the window
    -- from the list may already be gone; check each one right before touching it
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local floating = vim.api.nvim_win_get_config(win).relative ~= ""
      if (popup_ft[ft] or floating) and not ft:match("^snacks_notif") then
        pcall(vim.api.nvim_win_close, win, false) -- fails harmlessly on the last window
      end
    end
  end
end
map({ "n", "i", "t" }, "<M-q>", close_popups, { desc = "Close popups" })
map("n", "<leader>q", close_popups, { desc = "Close popups" })

-- ctrl+. (VSCode quick fix) = code action; alt+. as a fallback for terminals that drop the Ctrl
-- ts_ls also lists actions that can't apply here, marked disabled; hide them
function _G.code_action()
  vim.lsp.buf.code_action({ filter = function(a) return not a.disabled end })
end
map({ "n", "i", "v" }, "<C-.>", _G.code_action, { desc = "Code action" })
map({ "n", "i", "v" }, "<M-.>", _G.code_action, { desc = "Code action" })

-- markdown: SPC o m renders the file with glow in a buffer (vim motions and / work, q goes back)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    map("n", "<leader>om", function()
      local file = vim.api.nvim_buf_get_name(ev.buf)
      if file == "" then return vim.notify("Save the file first", vim.log.levels.WARN) end
      vim.cmd("silent update") -- glow reads the file on disk
      local win = vim.api.nvim_get_current_win()
      local width = math.min(vim.api.nvim_win_get_width(win) - 8, 100)
      vim.cmd("enew")
      local view = vim.api.nvim_get_current_buf()
      vim.bo[view].bufhidden = "wipe"
      vim.fn.jobstart({ "glow", "-s", "light", "-w", tostring(width), file }, {
        term = true,
        on_exit = function()
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == view then
              vim.api.nvim_win_set_cursor(win, { 1, 0 }) -- start reading from the top
            end
          end)
        end,
      })
      map("n", "q", function() vim.api.nvim_win_set_buf(win, ev.buf) end, { buffer = view, desc = "Back to the file" })
    end, { buffer = ev.buf, desc = "Read with glow" })
  end,
})
-- ctrl+` (VSCode). Many terminals send Ctrl+` as <Nul>, so bind both.
map({ "n", "i", "t" }, "<C-`>", toggle_term, { desc = "Toggle terminal" })
map({ "n", "i", "t" }, "<C-@>", toggle_term, { desc = "Toggle terminal" })

-- VSCode-style keys, kept alongside the SPC ones
map("n", "<C-p>", tb("find_files"), { desc = "Find file in project" })
map("n", "<C-t>", tb("lsp_dynamic_workspace_symbols"), { desc = "Find symbol in workspace" })

-- change directory
map("n", "<leader>cd", function()
  vim.cmd("cd %:p:h")
  vim.notify("cwd: " .. vim.fn.getcwd())
end, { desc = "cd to this file's folder" })
map("n", "<leader>cD", function()
  local root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and root then
    vim.cmd("cd " .. vim.fn.fnameescape(root))
    vim.notify("cwd: " .. root)
  else
    vim.notify("not in a git repo", vim.log.levels.WARN)
  end
end, { desc = "cd to git root" })
map("n", "<leader>hb", tb("keymaps"), { desc = "Search keybinds" })
map("n", "<leader>hk", tb("keymaps"), { desc = "Search keybinds" })

-- rename through oil also updates imports
vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
    for _, a in ipairs(event.data.actions or {}) do
      if a.type == "move" then Snacks.rename.on_rename_file(a.src_url, a.dest_url) end
    end
  end,
})

-- bottom statusline: flags, diagnostic counts, position.
-- The four counts always show, each with an icon; a zero is plain, a non-zero count is colored.
local diag_items = {
  { vim.diagnostic.severity.ERROR, "\u{f057}", "DiagnosticError" },
  { vim.diagnostic.severity.WARN, "\u{f071}", "DiagnosticWarn" },
  { vim.diagnostic.severity.INFO, "\u{f05a}", "DiagnosticInfo" },
  { vim.diagnostic.severity.HINT, "\u{f0eb}", "DiagnosticHint" }, -- e.g. "declared but never read"
}
function _G.diag_status()
  local c = vim.diagnostic.count(0)
  local out = {}
  for _, d in ipairs(diag_items) do
    local n = c[d[1]] or 0
    table.insert(out, (n > 0 and "%#" .. d[3] .. "#" or "%*") .. d[2] .. " " .. n .. "%*")
  end
  return table.concat(out, "  ") .. " "
end
-- current project: the working directory (follows :cd, so also Oil's `)
function _G.project_name()
  return "[ " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "]"
end
-- git branch of the working directory, e.g. [ main]; empty outside a repo.
-- Watches the git dir (git replaces HEAD by rename, so a watch on the file itself would go stale),
-- so a checkout from any terminal shows up right away. Detached HEAD shows the short commit.
local git_branch, git_dir, git_watcher = "", "", nil
local git_refresh
local function git_watch(dir)
  if dir == git_dir then return end
  git_dir = dir
  if git_watcher then git_watcher:close() git_watcher = nil end
  if dir == "" then return end
  git_watcher = vim.uv.new_fs_event()
  git_watcher:start(dir, {}, vim.schedule_wrap(function(_, file)
    if file == "HEAD" then git_refresh() end
  end))
end
git_refresh = function()
  local cwd = vim.fn.getcwd()
  local function git(args, cb)
    vim.system(vim.list_extend({ "git", "-C", cwd }, args), { text = true }, vim.schedule_wrap(function(r)
      if cwd == vim.fn.getcwd() then cb(r.code == 0 and vim.trim(r.stdout) or "") end -- drop results from before a :cd
    end))
  end
  local function show(name)
    git_branch = name
    vim.cmd.redrawstatus()
  end
  git({ "rev-parse", "--absolute-git-dir" }, function(dir)
    git_watch(dir)
    if dir == "" then return show("") end
    git({ "branch", "--show-current" }, function(name)
      if name ~= "" then return show(name) end
      git({ "rev-parse", "--short", "HEAD" }, show)
    end)
  end)
end
function _G.git_status()
  return git_branch == "" and "" or "[\u{f418} " .. git_branch .. "]"
end
vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained" }, { callback = git_refresh }) -- FocusGained: catches a `git init`
vim.api.nvim_create_autocmd("DirChanged", { callback = function() vim.cmd.redrawstatus() end })
git_refresh()
-- file language, e.g. [Markdown]; empty when no filetype
function _G.lang_status()
  local ft = vim.bo.filetype
  return ft == "" and "" or " [" .. ft:sub(1, 1):upper() .. ft:sub(2) .. "]"
end
-- the file path and symbol breadcrumb live in the winbar (dropbar.nvim), so the statusline
-- only names windows that have no winbar: terminal, help, quickfix, Oil...
function _G.name_status()
  return (vim.bo.buftype ~= "" or vim.bo.filetype == "oil") and " %t" or ""
end
vim.opt.statusline = "%{v:lua.project_name()}%{v:lua.git_status()}%{%v:lua.name_status()%} %m%r%h%w %{%v:lua.diag_status()%}%=%l:%c %P%{v:lua.lang_status()}"

-- top line (own row): the current file's path as plain text on the left, compact harpoon slots on the
-- right (just the numbers, current file highlighted; SPC 1-4 jump, SPC h h lists the names).
-- %< cuts a too-long path from its left end, so the slots never get pushed around.
-- The row under it is dropbar's symbol breadcrumb.
function _G.harpoon_tabline()
  local name = vim.api.nvim_buf_get_name(0)
  local current = vim.fn.fnamemodify(name, ":.")
  local parts = { "%#TabLineFill# [󰀱]" } -- then one bracketed slot each: [󰀱] [1] [2]
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    for i, item in ipairs(harpoon:list().items) do
      table.insert(parts, "%#TabLineFill# " .. (item.value == current and "%#TabLineSel#" or "%#TabLine#") .. "[" .. i .. "]")
    end
  end
  local real = name ~= "" and vim.bo.buftype == "" and vim.bo.filetype ~= "oil"
  local path = real and vim.fn.fnamemodify(name, ":~:."):gsub("%%", "%%%%") or ""
  local left = path == "" and "" or " %<" .. path
  return "%#TabLineFill#" .. left .. "%=" .. table.concat(parts) .. "%#TabLineFill# "
end
vim.opt.showtabline = 2
vim.opt.tabline = "%{%v:lua.harpoon_tabline()%}"
