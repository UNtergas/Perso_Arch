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
    -- Alabaster with its own default colours, no patches. Installed and loaded, but koda-glade (below) is the startup
    -- colour scheme; `:Theme alabaster` switches to it.
    "dchinmay2/alabaster.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "light"
      -- treesitter highlighting is not on by default for TS/JS
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
      })
    end,
  },

  -- Startup colour scheme: koda-glade (loads after alabaster, priority 1000). Other schemes: :Theme <name>
  {
    "oskarnurm/koda.nvim",
    lazy = false,
    priority = 900,
    config = function()
      -- koda-glade: dim the background a little (its #f7f7f7 is too bright). Every group that uses koda's background
      -- gets the new one; the string/type colours are light, so only a small step (#f3f3f3 keeps strings at about
      -- 3.8:1 contrast). Registered before the scheme loads so it also applies at startup.
      local koda_glade_bg = 0xf3f3f3
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "koda-glade",
        callback = function()
          local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
          if not normal_bg then return end
          for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
            if hl.bg == normal_bg and not hl.link then
              vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", hl, { bg = koda_glade_bg }))
            end
          end
        end,
      })
      vim.cmd.colorscheme("koda-glade")
    end,
  },
  -- installed but NOT loaded at startup; switch with :Theme onedark-<style>
  { "navarasu/onedark.nvim", lazy = true },

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
        "kotlin",
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
        "kotlin_language_server",
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

      -- Kotlin: JetBrains kotlin-lsp (alpha), unpacked under kvim's own data dir (not on $PATH).
      -- It needs a Gradle/Maven project root, so no single-file mode.
      vim.lsp.config("kotlin_lsp", {
        cmd = { vim.fn.stdpath("data") .. "/kotlin-lsp/current/bin/intellij-server", "--stdio" },
        single_file_support = false,
      })
      -- kotlin_language_server's embedded Kotlin compiler can't parse Java 25.0.4.1 ("IllegalArgumentException: 25.0.4.1"),
      -- so run it on JDK 21 (kvim only; the system default stays 25)
      -- It also answers workspace/symbol with `location = { uri }` and no range (valid LSP 3.17), and
      -- vim.lsp.util.symbols_to_items drops entries without a range, so Telescope (Ctrl-T) showed nothing.
      -- Fill the range in: find the declaration line (class / fun / val ...) of the symbol in its file.
      local decl_kw = { "class", "interface", "object", "fun", "val", "var", "typealias" }
      local function fill_symbol_ranges(result)
        local files = {}
        for i, sym in ipairs(result) do
          local loc = sym.location
          if i > 80 then break end
          if loc and not loc.range and loc.uri then
            local lines = files[loc.uri]
            if lines == nil then
              local ok, l = pcall(vim.fn.readfile, vim.uri_to_fname(loc.uri))
              lines = ok and l or false
              files[loc.uri] = lines
            end
            local line, col = 0, 0
            for n, text in ipairs(lines or {}) do
              local s, e = text:find(sym.name, 1, true)
              while s do
                local before, after = text:sub(1, s - 1), text:sub(e + 1, e + 1)
                local inside = (s > 1 and text:sub(s - 1, s - 1):match("[%w_]")) or after:match("[%w_]")
                if not inside then
                  for _, k in ipairs(decl_kw) do
                    if before:find("%f[%w]" .. k .. "%s") then line, col = n - 1, s - 1 break end
                  end
                end
                if line ~= 0 or col ~= 0 then break end
                s, e = text:find(sym.name, e + 1, true)
              end
              if line ~= 0 or col ~= 0 then break end
            end
            loc.range = { start = { line = line, character = col }, ["end"] = { line = line, character = col + #sym.name } }
          end
        end
      end
      -- Library sources (kotlin.*, kotlinx.*): the server resolves these imports (hover works) but gives no location
      -- for them, so gd found nothing. Open the declaration from the newest sources jar in Gradle's cache instead
      -- (read-only copy, extracted once under stdpath("cache")/kotlin-sources).
      local gradle_cache = vim.fn.expand("~/.gradle/caches/modules-2/files-2.1")
      local function version_newer(a, b)
        local function parts(v) local t = {} for n in v:gmatch("%d+") do t[#t + 1] = tonumber(n) end return t end
        local pa, pb = parts(a), parts(b)
        for i = 1, math.max(#pa, #pb) do
          local x, y = pa[i] or 0, pb[i] or 0
          if x ~= y then return x > y end
        end
        return false
      end
      local function newest_sources_jars(group)
        local newest = {} -- artifact -> { version, jar }
        for _, jar in ipairs(vim.fn.glob(gradle_cache .. "/" .. group .. "/*/*/*/*-sources.jar", false, true)) do
          local artifact, version = jar:match("/([^/]+)/([^/]+)/[^/]+/[^/]+$")
          if artifact and (not newest[artifact] or version_newer(version, newest[artifact].version)) then
            newest[artifact] = { version = version, jar = jar }
          end
        end
        local list = vim.tbl_values(newest)
        -- newest version first (kotlin-stdlib 2.x before the old kotlin-stdlib-common), then by path
        table.sort(list, function(a, b)
          if a.version ~= b.version then return version_newer(a.version, b.version) end
          return a.jar < b.jar
        end)
        return list
      end
      -- line / column of the declaration of `word` in a file's lines (top-level one preferred)
      local function find_declaration(lines, word)
        local fallback
        for n, text in ipairs(lines) do
          if not text:match("^%s*[%*/]") then -- skip KDoc and comments
            local s, e = text:find(word, 1, true)
            while s do
              local before, after = text:sub(1, s - 1), text:sub(e + 1, e + 1)
              local inside = (s > 1 and text:sub(s - 1, s - 1):match("[%w_]")) or after:match("[%w_]")
              if not inside then
                for _, k in ipairs(decl_kw) do
                  -- the name must be what is declared: `class Foo`, `fun <T> Receiver<T>.foo(`, `val foo`; not a later mention
                  local declared
                  if k == "fun" or k == "val" or k == "var" then
                    local seg = before:match("%f[%w]" .. k .. "%s(.*)$")
                    declared = seg ~= nil and not seg:find("[(=:]")
                  else
                    declared = before:find("%f[%w]" .. k .. "%s+$") ~= nil
                  end
                  if declared then
                    if not text:match("^%s") then return n, s - 1 end
                    fallback = fallback or { n, s - 1 }
                  end
                end
              end
              s, e = text:find(word, e + 1, true)
            end
          end
        end
        if fallback then return fallback[1], fallback[2] end
      end
      local function library_definition(word)
        local pkg
        for _, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
          pkg = pkg or text:match("^import%s+([%w_.]+)%." .. word .. "%s*$")
        end
        local group = pkg and ((pkg == "kotlinx" or pkg:match("^kotlinx%.")) and "org.jetbrains.kotlinx"
          or (pkg == "kotlin" or pkg:match("^kotlin%.")) and "org.jetbrains.kotlin")
        if group then
          for _, src in ipairs(newest_sources_jars(group)) do
            local out = vim.fn.stdpath("cache") .. "/kotlin-sources/" .. src.jar:match("([^/]+)%-sources%.jar$")
            if vim.fn.isdirectory(out) == 0 then
              vim.fn.mkdir(out, "p")
              vim.fn.system({ "unzip", "-o", "-q", src.jar, "-d", out }) -- blocking, no event loop (vim.system():wait() runs other callbacks)
            end
            for _, file in ipairs(vim.fn.glob(out .. "/**/*.kt", false, true)) do
              local lines = vim.fn.readfile(file)
              local in_pkg = false
              for i = 1, math.min(#lines, 60) do
                if vim.trim(lines[i]) == "package " .. pkg then in_pkg = true break end
              end
              local line, col
              if in_pkg then line, col = find_declaration(lines, word) end
              if line then
                vim.cmd(("edit +%d %s"):format(line, vim.fn.fnameescape(file))) -- +line: placed after the read autocmds
                vim.bo.modifiable, vim.bo.readonly = false, true
                local buf = vim.api.nvim_get_current_buf()
                local function place()
                  if vim.api.nvim_get_current_buf() == buf then
                    pcall(vim.api.nvim_win_set_cursor, 0, { line, col })
                    vim.cmd("normal! zz")
                  end
                end
                place()
                vim.defer_fn(place, 150) -- a freshly loaded buffer can get its cursor reset by autocmds / plugins after :edit
                return
              end
            end
          end
        end
        vim.notify("No definition found for " .. word, vim.log.levels.INFO)
      end
      -- gd for Kotlin buffers. When a module has compiled output in its build/ folder, the server resolves top-level
      -- functions (isLegacyJWT, getTokenType ...) to the compiled class and textDocument/definition comes back empty,
      -- while classes still work. Fall back to the server's workspace symbol search for the exact name.
      local function kotlin_definition()
        local word = vim.fn.expand("<cword>")
        local function jump(items)
          if #items == 1 then
            local it = items[1]
            vim.lsp.util.show_document({
              uri = vim.uri_from_fname(it.filename),
              range = { start = { line = it.lnum - 1, character = it.col - 1 }, ["end"] = { line = it.lnum - 1, character = it.col - 1 } },
            }, "utf-16", { focus = true })
          else
            vim.fn.setqflist({}, " ", { title = "Definitions of " .. word, items = items })
            vim.cmd("copen")
          end
        end
        -- raw request: vim.lsp.buf.definition never calls on_list for an empty result, it just says "No locations found"
        local client = vim.lsp.get_clients({ bufnr = 0, name = "kotlin_language_server" })[1]
        local enc = client and client.offset_encoding or "utf-16"
        vim.lsp.buf_request(0, "textDocument/definition", vim.lsp.util.make_position_params(0, enc), function(err, result)
          local locs = (not err and result) and (vim.islist(result) and result or { result }) or {}
          if #locs > 0 then return jump(vim.lsp.util.locations_to_items(locs, enc)) end
          vim.lsp.buf_request(0, "workspace/symbol", { query = word }, function(err2, syms, ctx)
            local c = ctx and vim.lsp.get_client_by_id(ctx.client_id)
            local exact = {}
            for _, sym in ipairs(not err2 and type(syms) == "table" and syms or {}) do
              if sym.name == word then table.insert(exact, sym) end
            end
            local items = #exact > 0 and vim.lsp.util.symbols_to_items(exact, 0, c and c.offset_encoding or enc) or {}
            if #items == 0 then return library_definition(word) end
            jump(items)
          end)
        end)
      end
      vim.lsp.config("kotlin_language_server", {
        cmd_env = { JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-amd64" },
        -- keep the server's symbol index (kls_database.db) out of the projects: a stale one left in a project root
        -- made `gd` fail on top-level functions (isLegacyJWT, getTokenType) while classes still worked
        before_init = function(params)
          -- one folder per project root, so projects never share an index
          local root = params.rootPath or (params.rootUri and vim.uri_to_fname(params.rootUri)) or vim.fn.getcwd()
          local dir = vim.fn.stdpath("cache") .. "/kotlin-language-server/" .. vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8)
          vim.fn.mkdir(dir, "p")
          params.initializationOptions = vim.tbl_extend("force", params.initializationOptions or {}, { storagePath = dir })
        end,
        on_attach = function(client)
          if client._kvim_symbol_fix then return end
          client._kvim_symbol_fix = true
          local request = client.request
          client.request = function(self, method, params, handler, bufnr)
            if method == "workspace/symbol" and handler then
              local inner = handler
              handler = function(err, result, ctx, config)
                if type(result) == "table" then pcall(fill_symbol_ranges, result) end
                return inner(err, result, ctx, config)
              end
            end
            return request(self, method, params, handler, bufnr)
          end
        end,
      })
      -- vim.lsp.enable("kotlin_lsp") -- off: its Gradle import fails on AGP 8.13.2 (see snowpack-android); using kotlin_language_server (Mason)

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
          local attached = vim.lsp.get_client_by_id(event.data.client_id)
          m("gd", (attached and attached.name == "kotlin_language_server") and kotlin_definition or vim.lsp.buf.definition, "Go to definition")
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
      pickers = {
        -- old file versions (githist://<hash>/<path>) are listed as just <hash>/<filename>
        buffers = {
          path_display = function(_, path)
            return _G.githist_label(path) or vim.fn.fnamemodify(path, ":~:.")
          end,
        },
      },
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
      -- kotlin_language_server needs 1-2 min after opening a Gradle project before it answers documentSymbol;
      -- the default (60 retries, 1 s apart) gives up first and leaves the bar on the noisy treesitter fallback
      sources = { lsp = { request = { ttl_init = 300 } } },
      bar = {
        -- the default sources minus `path`
        sources = function(buf)
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")
          if vim.bo[buf].ft == "markdown" then return { sources.markdown } end
          if vim.bo[buf].buftype == "terminal" then return { sources.terminal } end
          -- file name first, so the bar is never empty outside a function (full path is in the tabline)
          local file = {
            get_symbols = function(b)
              local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
              local icon, hl = require("dropbar.configs").opts.icons.kinds.file_icon(name)
              return { require("dropbar.bar").dropbar_symbol_t:new({ name = name, icon = icon, icon_hl = hl }) }
            end,
          }
          return { file, utils.source.fallback({ sources.lsp, sources.treesitter }) }
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
      { "<leader>sR", function() require("grug-far").open({ transient = true }) end, mode = { "n", "v" }, desc = "Search and replace (grouped by file)" },
      -- same UI, limited to the current file (word under cursor prefilled)
      { "<leader>sr", function()
        require("grug-far").open({ transient = true, prefills = { search = vim.fn.expand("<cword>"), paths = vim.fn.expand("%") } })
      end, desc = "Search and replace in this file" },
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
      require("harpoon"):extend({ LIST_CHANGE = function() vim.cmd.redrawstatus() vim.cmd.redrawtabline() end })
    end,
  },

  -- Indent guides: light gray everywhere; only the guide of the block the cursor is in gets its level colour
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = not vim.g.vscode,
    main = "ibl",
    config = function()
      local ibl = require("ibl")
      local hooks = require("ibl.hooks")
      local names = { "IblL1", "IblL2", "IblL3", "IblL4", "IblL5", "IblL6" }
      local colors = { "#d98a8a", "#d9b25f", "#7fae6f", "#5fa8b8", "#7d95d6", "#b58ad6" }
      -- mix a colour into the background: share = how much of the colour (0..1)
      local function tint(hex, share)
        local bg = { 0xf5, 0xf5, 0xf5 }
        local out = {}
        for i = 1, 3 do
          local c = tonumber(hex:sub(2 * i, 2 * i + 1), 16)
          out[i] = math.floor(bg[i] + (c - bg[i]) * share + 0.5)
        end
        return ("#%02x%02x%02x"):format(out[1], out[2], out[3])
      end
      local share = 0.3 -- strength of the tint, used by both the band and the active guide
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#d6d6d6" })
        for k, name in ipairs(names) do
          vim.api.nvim_set_hl(0, name, { fg = tint(colors[k], share) }) -- active guide: same colour as the band
        end
        -- ibl paints the opening line of the block (from the guide's column to the end of the text) with these
        -- groups, as a thin terminal underline. A terminal draws that underline itself, thin and detached from the
        -- guide, so use a tinted band in the level colour instead: a thick bar that starts at the guide.
        -- ibl creates the groups right after this hook, so replace them one tick later.
        vim.schedule(function()
          for k in ipairs(names) do
            vim.api.nvim_set_hl(0, "@ibl.scope.underline." .. k, { bg = tint(colors[k], share) })
          end
        end)
      end)
      -- ibl only counts functions and statement blocks as scopes by default, so inside `where: { ... }` it
      -- jumped up to the whole method. Add the other bracket pairs, so the innermost { } [ ] ( ) is the scope.
      local brackets = {
        "object", "array", "arguments", "formal_parameters", "class_body", "interface_body", "enum_body",
        "switch_body", "object_pattern", "object_type", "named_imports",
      }
      ibl.setup({
        indent = { char = "│", highlight = "IblIndent" }, -- inactive guides: thin, light gray
        -- the scope is the bracket pair / block (treesitter) around the cursor; a list here is picked by its
        -- depth, so level 1 is red, level 2 yellow... as before. Its guide is the thick ▎ in the same tint as
        -- the band on the opening line (the "underline" groups above), so the two read as one shape.
        scope = {
          enabled = true,
          highlight = names,
          -- left three-eighths block: thicker than │ and flush with the left edge of its cell, so it meets
          -- the band on the opening line, which starts at the same column's left edge.
          -- ▏ 1/8, ▎ 2/8, ▍ 3/8, ▌ 4/8 of the cell width
          char = "▍",
          show_start = true,
          show_end = true,
          include = { node_type = { typescript = brackets, tsx = brackets, javascript = brackets } },
        },
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
  { -- git graph buffer, see SPC g l. Enter on a commit opens it in Diffview; Enter in visual mode diffs the range.
    "isakbm/gitgraph.nvim",
    lazy = true,
    opts = {
      format = { timestamp = "%Y-%m-%d %H:%M", fields = { "hash", "timestamp", "author", "branch_name", "tag" } },
      hooks = {
        on_select_commit = function(c) vim.cmd("DiffviewOpen " .. c.hash .. "^!") end,
        on_select_range_commit = function(from, to) vim.cmd("DiffviewOpen " .. from.hash .. "~1.." .. to.hash) end,
      },
    },
  },
  { -- 3-way merge tool: ours | merged (edit here) | theirs
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
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
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    -- tsx: its default query paints JSX tag names and < > in the bracket-depth colours; "rainbow-parens"
    -- keeps the rainbow on ( ) [ ] { } only, so tag names get Alabaster's blue instead
    init = function() vim.g.rainbow_delimiters = { query = { tsx = "rainbow-parens" } } end,
  },
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
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    init = function() vim.g.undotree_SetFocusWhenToggle = 1 end, -- SPC s u moves the cursor into the tree
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      notify.setup({ timeout = 3000, render = "compact", stages = "fade", background_colour = "#ededed" })
      vim.notify = notify -- every vim.notify call in this config (and plugins) goes through it
      -- Alabaster-friendly colours (the defaults are neon green / pale yellow); darker than the
      -- diagnostic signs so they stay readable as text on the light grey background
      local function colours()
        local lvl = { ERROR = "#c62828", WARN = "#a86400", INFO = "#325cc0", DEBUG = "#6a6a6a", TRACE = "#7b4fa3" }
        for name, fg in pairs(lvl) do
          for _, part in ipairs({ "Border", "Icon", "Title" }) do
            vim.api.nvim_set_hl(0, "Notify" .. name .. part, { fg = fg })
          end
          vim.api.nvim_set_hl(0, "Notify" .. name .. "Body", { fg = "#333333", bg = "#ededed" })
        end
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#ededed" })
      end
      colours()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = colours })
    end,
  },
  {
    -- statusline + tabline (encoding > path > git counts ... harpoon slots); no winbar section, dropbar owns that.
    -- Same content as the old hand-written statusline (project, branch, name, flags, diagnostics | macro, search, lang, position), lualine styling
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- "auto" follows the colorscheme, but gives sections b and c the same background, which hides the
      -- arrow between them (folder > branch > diagnostics): give b its own, in between a and c
      local theme = require("lualine.themes.auto")
      for _, m in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
        if theme[m] and theme[m].b then theme[m].b = { fg = "#222222", bg = "#b8b8b8" } end
      end
      -- "#rrggbb" foreground of a highlight group (lualine wants a hex string, not the number nvim returns)
      _G.hl_hex = function(name)
        local fg = vim.api.nvim_get_hl(0, { name = name, link = false }).fg
        return fg and string.format("#%06x", fg) or "#888888"
      end
      -- the Kotlin icon in the tabline follows the LSP state, so redraw it when a server attaches, detaches or reports progress
      vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "LspProgress" }, {
        callback = function() vim.schedule(function() vim.cmd.redrawtabline() end) end,
      })
      require("lualine").setup({
        options = {
          theme = theme, -- section a changes colour with the mode
          globalstatus = false,
          component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
          section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
        },
        sections = {
          lualine_a = { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end },
          lualine_b = { { "branch", icon = "\u{f418}" } },
          lualine_c = {
            -- error / warn / hint always show (zeros too); info only when there is one
            { "diagnostics", sections = { "error", "warn", "hint" }, always_visible = true,
              symbols = { error = "\u{f057} ", warn = "\u{f071} ", hint = "\u{f0eb} " } },
            { "diagnostics", sections = { "info" }, symbols = { info = "\u{f05a} " } },
            -- terminal / help / quickfix / Oil have no winbar, so the statusline names them
            function()
              if _G.githist_label(vim.api.nvim_buf_get_name(0)) then return "" end
              return (vim.bo.buftype ~= "" or vim.bo.filetype == "oil") and vim.fn.expand("%:t") or ""
            end,
            function() return vim.trim(_G.flags_status()) end,
          },
          lualine_x = {
            function() local r = vim.fn.reg_recording() return r == "" and "" or "\u{f111} @" .. r end,
            { "searchcount", maxcount = 999, timeout = 100 },
            { "lsp_status", icon = "\u{f085}", symbols = { spinner = {}, done = "", separator = " " } }, -- attached server names, no spinner
          },
          lualine_y = { { "filetype", colored = false, fmt = function(s) return s:lower() end } },
          lualine_z = { "progress", "location" },
        },
        -- top row: encoding > path > git counts ........ harpoon slots (replaces harpoon_tabline once lualine loads)
        tabline = {
          lualine_a = {
            -- kvim only: Kotlin icon, always first. Its colour is the LSP state:
            --   grey = no Kotlin server attached to this buffer, amber = attached but busy (importing Gradle / indexing),
            --   purple = attached and idle (ready)
            {
              function() return "\u{e634}" end,
              separator = "",
              color = function()
                local clients = vim.lsp.get_clients({ bufnr = 0, name = "kotlin_language_server" })
                if #clients == 0 then return { fg = "#8a8a8a" } end
                if vim.lsp.status() ~= "" then return { fg = "#d98c00" } end
                return { fg = "#7f52ff" }
              end,
            },
            "encoding",
            "fileformat",
          },
          lualine_b = {
            {
              function()
                local name = vim.api.nvim_buf_get_name(0)
                local label = _G.githist_label(name)
                local path = label
                if not path then
                  local real = name ~= "" and vim.bo.buftype == "" and vim.bo.filetype ~= "oil"
                  path = real and vim.fn.fnamemodify(name, ":~:.") or ""
                end
                if path == "" then return "" end
                local max = math.max(20, vim.o.columns - 70) -- cut a too-long path from its left end
                if vim.fn.strdisplaywidth(path) > max then path = "\u{2026}" .. vim.fn.strcharpart(path, vim.fn.strchars(path) - max + 1) end
                return path .. (vim.bo.modified and " \u{f444}" or "") -- dark blue dot: unsaved changes
              end,
              color = function() return vim.bo.modified and { fg = "#1f4e9c" } or nil end,
            },
          },
          lualine_c = {
            {
              "diff", -- from gitsigns (b:gitsigns_status_dict)
              symbols = { added = "\u{f0fe} ", modified = "\u{f14b} ", removed = "\u{f146} " },
              diff_color = {
                added = function() return { fg = _G.hl_hex("Added") } end,
                modified = function() return { fg = "#a57c00" } end,
                removed = function() return { fg = _G.hl_hex("Removed") } end,
              },
            },
          },
          lualine_x = (function()
            -- harpoon: [󰀱] then one slot each, the current file's slot highlighted (SPC 1-4 jump, SPC h h lists)
            local parts = {
              {
                function()
                  local ok, harpoon = pcall(require, "harpoon")
                  return ok and #harpoon:list().items > 0 and "[\u{f0031}]" or ""
                end,
                separator = "",
              },
            }
            for i = 1, 9 do
              table.insert(parts, {
                function()
                  local ok, harpoon = pcall(require, "harpoon")
                  return ok and harpoon:list().items[i] and "[" .. i .. "]" or ""
                end,
                separator = "",
                padding = { left = 1, right = 0 },
                color = function()
                  local ok, harpoon = pcall(require, "harpoon")
                  local item = ok and harpoon:list().items[i]
                  if item and item.value == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.") then return "TabLineSel" end
                  return "TabLine"
                end,
              })
            end
            return parts
          end)(),
        },
        inactive_sections = { lualine_c = { "filename" }, lualine_x = { "location" } },
      })
    end,
  },
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
map("n", "<Esc>", "<cmd>nohlsearch<bar>redrawstatus<cr>", { desc = "Clear highlight" })

-- IDE-style selection: shift+arrows/home/end start a selection, typing replaces it,
-- plain movement drops it. ctrl+shift+arrow = shift+arrow (vim's <S-Left>/<S-Right> already move by word).
vim.opt.keymodel = "startsel,stopsel"
vim.opt.selectmode = "key"
for key, w in pairs({ ["<C-S-Left>"] = "b", ["<C-S-Right>"] = "w" }) do
  map("i", key, "<C-o>v" .. w .. "<C-g>", { desc = "Select word" })
  map("n", key, "v" .. w .. "<C-g>", { desc = "Select word" })
  map("x", key, w, { desc = "Select word" })
  map("s", key, "<C-o>" .. w, { desc = "Select word" })
end

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

-- scroll: <C-d>/<C-f>/<C-b> are taken above, so the native scrolls live on other keys
-- (normal! ignores mappings, so it reaches the built-in <C-d>/<C-u>)
map({ "n", "x" }, "<C-j>", [[<Cmd>exe "normal! \<C-d>"<CR>]], { desc = "Half page down" })
map({ "n", "x" }, "<C-k>", [[<Cmd>exe "normal! \<C-u>"<CR>]], { desc = "Half page up" })
-- <PageDown>/<PageUp> are already full-page scroll natively

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
-- VSCode: Ctrl+\ splits side by side, Ctrl+K \ splits stacked
map("n", "<C-\\>", "<cmd>rightbelow vsplit<cr>", { desc = "Split side by side" })
map(ck, "<C-k>\\", "<cmd>rightbelow split<cr>", { desc = "Split stacked" })
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
-- SPC g g: lazygit (floating); SPC g f: lazygit log of this file
map("n", "<leader>gg", function() Snacks.lazygit.open() end, { desc = "Lazygit" })
map("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit: this file's history" })
-- Old versions of a file as ordinary read-only buffers named githist://<hash>/<path>. The content is loaded
-- by a BufReadCmd, so :edit, harpoon and sessions can reopen them. buftype=nofile + nomodifiable: no :w.
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "githist://*",
  callback = function(ev)
    local hash, rel = ev.match:match("^githist://([^/]+)/(.+)$")
    if not hash then return end
    local from = vim.fn.expand("#:p:h")
    local r
    for _, cwd in ipairs({ vim.fn.getcwd(), from ~= "" and from or nil }) do
      r = vim.system({ "git", "show", hash .. ":" .. rel }, { cwd = cwd }):wait()
      if r.code == 0 then break end
    end
    if r.code ~= 0 then
      vim.notify("git show " .. hash .. ":" .. rel .. " failed (file missing at that commit, or not run from the repo)", vim.log.levels.ERROR)
      return
    end
    local lines = vim.split(r.stdout, "\n", { plain = true })
    if lines[#lines] == "" then table.remove(lines) end
    local b = ev.buf
    vim.bo[b].modifiable = true
    vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
    vim.bo[b].buftype, vim.bo[b].bufhidden, vim.bo[b].swapfile = "nofile", "hide", false
    vim.bo[b].filetype = vim.filetype.match({ filename = rel, contents = lines }) or ""
    vim.bo[b].modifiable, vim.bo[b].readonly, vim.bo[b].modified = false, true, false
  end,
})
-- SPC g v: pick a commit that touched this file, open that version as a read-only buffer.
map("n", "<leader>gv", function()
  local path = vim.api.nvim_buf_get_name(0)
  local dir = vim.fs.dirname(path)
  local rel = vim.system({ "git", "-C", dir, "ls-files", "--full-name", "--", path }):wait().stdout:gsub("%s+$", "")
  if rel == "" then vim.notify("File is not tracked by git", vim.log.levels.WARN) return end
  local act, st = require("telescope.actions"), require("telescope.actions.state")
  require("telescope.builtin").git_bcommits({
    prompt_title = "Open old version (read-only)",
    attach_mappings = function(pb)
      act.select_default:replace(function()
        local hash = st.get_selected_entry().value:sub(1, 8)
        act.close(pb)
        -- the file may have had another path back then (renames): ask git for its name at that commit
        local at = rel
        local out = vim.system({ "git", "-C", dir, "log", "--follow", "--name-only", "--format=C:%h", "--", path }):wait().stdout or ""
        local cur
        for line in out:gmatch("[^\r\n]+") do
          local h = line:match("^C:(%x+)$")
          if h then cur = h:sub(1, 8) == hash and true or false
          elseif cur then at = line break end
        end
        vim.cmd("edit githist://" .. hash .. "/" .. vim.fn.fnameescape(at))
      end)
      return true
    end,
  })
end, { desc = "Open old version of file (read-only)" })
-- SPC g h: history of this file in Diffview (commit list + side-by-side diffs). In the commit panel,
-- X restores the file to the selected commit's version; SPC g q closes it. SPC g H: history of the whole repo.
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history (Diffview)" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repo history (Diffview)" })
-- SPC g l: git graph (gitgraph.nvim, all branches) in its own tab. Enter on a commit = Diffview of it.
-- Again, q or Alt-q closes it.
map("n", "<leader>gl", function()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.b[vim.api.nvim_win_get_buf(w)].git_graph then
      vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(vim.api.nvim_win_get_tabpage(w)))
      return
    end
  end
  local dir = vim.fn.expand("%:p:h")
  if dir == "" or vim.fn.isdirectory(dir) == 0 then dir = vim.fn.getcwd() end
  if vim.system({ "git", "-C", dir, "rev-parse", "--git-dir" }):wait().code ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  vim.cmd("tabnew")
  vim.cmd("tcd " .. vim.fn.fnameescape(dir))
  require("gitgraph").draw({}, { all = true, max_count = 5000 })
  local buf = vim.api.nvim_get_current_buf()
  vim.b[buf].git_graph = true
  local close = function() vim.cmd("tabclose") end
  for _, key in ipairs({ "q", "<A-q>", "<leader>gl" }) do
    vim.keymap.set("n", key, close, { buffer = buf, desc = "Close git graph" })
  end
end, { desc = "Git graph (toggle)" })

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
-- Esc Esc leaves terminal mode (a single Esc still goes to the program inside, e.g. vim / fzf)
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

-- Alt-q (or SPC q): close the popups (Trouble, quickfix, help, grug-far, undo tree, floats, bottom terminal), keep the files
local popup_ft = { trouble = true, qf = true, help = true, checkhealth = true, ["grug-far"] = true, ["grug-far-history"] = true }
local function close_popups()
  if vim.fn.mode() == "t" then vim.cmd("stopinsert") end
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    pcall(vim.api.nvim_win_hide, term.win)
    term.win = nil
  end
  -- the undo tree is two windows (tree + diff panel); its own hide command closes both
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "undotree" then
      pcall(vim.cmd, "UndotreeHide")
      break
    end
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
-- Ctrl+V pastes from the system clipboard in insert mode only (elsewhere it keeps its default)
map("i", "<C-v>", "<C-r><C-p>+", { desc = "Paste" })
map("n", "<C-S-t>", tb("lsp_document_symbols"), { desc = "Find symbol in this file" })
map("n", "<leader>so", tb("lsp_document_symbols"), { desc = "Find symbol in this file" })

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
-- Order: error, warning, hint, info. Each count has an icon; a zero is plain, a non-zero count is colored.
-- Error, warning and hint always show; info is rare, so it only shows when there is one (4th field).
local diag_items = {
  { vim.diagnostic.severity.ERROR, "\u{f057}", "DiagnosticError", true },
  { vim.diagnostic.severity.WARN, "\u{f071}", "DiagnosticWarn", true },
  { vim.diagnostic.severity.HINT, "\u{f0eb}", "DiagnosticHint", true }, -- e.g. "declared but never read"
  { vim.diagnostic.severity.INFO, "\u{f05a}", "DiagnosticInfo", false },
}
function _G.diag_status()
  local c = vim.diagnostic.count(0)
  local out = {}
  for _, d in ipairs(diag_items) do
    local n = c[d[1]] or 0
    if n > 0 or d[4] then
      table.insert(out, (n > 0 and "%#" .. d[3] .. "#" or "%*") .. d[2] .. " " .. n .. "%*")
    end
  end
  return table.concat(out, "  ") .. " "
end
-- current project: the working directory (follows :cd, so also Oil's `)
function _G.project_name()
  return "[" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):gsub("%%", "%%%%") .. "]"
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
  return git_branch == "" and "" or "[%#StatusBranch#\u{f418}%* " .. git_branch:gsub("%%", "%%%%") .. "]"
end
vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained" }, { callback = git_refresh }) -- FocusGained: catches a `git init`
vim.api.nvim_create_autocmd("DirChanged", { callback = function() vim.cmd.redrawstatus() end })
git_refresh()
-- file language with its icon (nvim-web-devicons), lowercase, e.g. [ typescript]; no icon if it has none,
-- nothing without a filetype
function _G.lang_status()
  local ft = vim.bo.filetype
  if ft == "" then return "" end
  local mark = ""
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local icon, hl = devicons.get_icon_by_filetype(ft)
    if icon then mark = (hl and "%#" .. hl .. "#" or "") .. icon .. "%* " end
  end
  return " [" .. mark .. ft:lower() .. "]"
end
-- [+] modified, [RO], [Help]... with a space in front, nothing when there are none
function _G.flags_status()
  -- old file versions (githist://): just a read-only marker, the name is in the tabline
  if vim.api.nvim_buf_get_name(0):match("^githist://") then return " [READ-ONLY]" end
  local f = vim.api.nvim_eval_statusline("%m%r%h%w", {}).str
  return f == "" and "" or " " .. f
end
-- the file path and symbol breadcrumb live in the winbar (dropbar.nvim), so the statusline
-- only names windows that have no winbar: terminal, help, quickfix, Oil...
-- githist://<hash>/<path/to/file> -> "<hash>/file", nil for any other name
function _G.githist_label(name)
  local hash, rel = (name or ""):match("^githist://([^/]+)/(.+)$")
  return hash and (hash .. "/" .. vim.fs.basename(rel)) or nil
end
function _G.name_status()
  if _G.githist_label(vim.api.nvim_buf_get_name(0)) then return "" end
  return (vim.bo.buftype ~= "" or vim.bo.filetype == "oil") and " %t" or ""
end
-- dark yellow for the changed-lines count (re-applied after a colorscheme change, which clears custom groups)
local function diff_changed_hl()
  vim.api.nvim_set_hl(0, "StatusDiffChanged", { fg = "#a57c00" })
  vim.api.nvim_set_hl(0, "StatusBranch", { fg = "#6f3fa0" }) -- dark purple branch icon
  vim.api.nvim_set_hl(0, "TabModified", { fg = "#1f4e9c" }) -- dark blue: path + dot of an unsaved buffer in the tabline
end
diff_changed_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = diff_changed_hl })
-- diff mode: changed lines light blue instead of Alabaster's yellow, changed words a stronger blue
local function diff_colors()
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#d6e6f7" })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#9cc8f0", bold = true })
end
diff_colors()
vim.api.nvim_create_autocmd("ColorScheme", { callback = diff_colors })
-- lines added / changed / removed in the current buffer (from gitsigns), each with an icon
-- (plus / pencil / minus square) and colored; zeros are left out
function _G.diff_status()
  local d = vim.b.gitsigns_status_dict
  if not d then return "" end
  local out = ""
  for _, x in ipairs({
    { d.added, "\u{f0fe}", "Added" },
    { d.changed, "\u{f14b}", "StatusDiffChanged" },
    { d.removed, "\u{f146}", "Removed" },
  }) do
    if (x[1] or 0) > 0 then out = out .. "  %#" .. x[3] .. "#" .. x[2] .. " " .. x[1] .. "%*" end
  end
  return out
end
-- macro being recorded, e.g. "● @q"
function _G.macro_status()
  local reg = vim.fn.reg_recording()
  return reg == "" and "" or "%#DiagnosticError#\u{f111} @" .. reg .. "%*  "
end
-- match under the cursor while a search highlight is on, e.g. "[3/12] "; Esc clears it
function _G.search_status()
  if vim.v.hlsearch == 0 then return "" end
  local ok, s = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 100 })
  if not ok or not s.total or s.total == 0 then return "" end
  return ("[%d/%d%s] "):format(s.current, s.total, s.incomplete == 0 and "" or "+")
end
-- the statusline doesn't redraw by itself when these change
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave", "CmdlineLeave" }, {
  callback = function() vim.schedule(vim.cmd.redrawstatus) end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function() vim.cmd.redrawstatus() vim.cmd.redrawtabline() end, -- the diff counts are in the tabline
})
vim.opt.statusline = "%{%v:lua.project_name()%}%{%v:lua.git_status()%}%{%v:lua.name_status()%}%{%v:lua.flags_status()%} %#NonText#•%* %{%v:lua.diag_status()%}%#NonText#•%*%=%{%v:lua.macro_status()%}%{v:lua.search_status()}%l:%c %P%{%v:lua.lang_status()%}"

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
  local label = _G.githist_label(name)
  if label then path = label:gsub("%%", "%%%%") end
  -- git diff counts of this file (+added ~changed -removed) sit right after the path
  -- unsaved changes: path and a small dot turn dark blue (like VSCode's dot)
  local mod = vim.bo.modified
  local left = path == "" and "" or " %<" .. (mod and "%#TabModified#" or "") .. path .. (mod and " \u{f444}" or "") .. "%#TabLineFill#" .. _G.diff_status() .. "%#TabLineFill#"
  return "%#TabLineFill#" .. left .. "%=" .. table.concat(parts) .. "%#TabLineFill# "
end
vim.api.nvim_create_autocmd("BufModifiedSet", { callback = function() vim.cmd.redrawtabline() end })
vim.opt.showtabline = 2
vim.opt.tabline = "%{%v:lua.harpoon_tabline()%}"

-- cowboy: after LIMIT hjkl/arrow/+/- presses within 2s of the first one (no count), the key is blocked until the window ends.
-- Use w b f t / } instead. A count (5j) resets it; nofile buffers (Oil, pickers) are exempt.
local LIMIT = 7
for _, key in ipairs({ "h", "j", "k", "l", "+", "-", "<Left>", "<Down>", "<Up>", "<Right>" }) do
  local count, timer = 0, assert(vim.uv.new_timer())
  vim.keymap.set("n", key, function()
    if vim.v.count > 0 then count = 0 end
    if count >= LIMIT and vim.bo.buftype ~= "nofile" then
      -- expr maps run under textlock: nvim-notify opens a window, so defer it
      vim.schedule(function() vim.notify("Hold it Cowboy! 🤠", vim.log.levels.WARN, { icon = "🤠", id = "cowboy" }) end)
      return ""
    end
    if count == 0 then timer:start(2000, 0, function() count = 0 end) end -- fixed window from the first press
    count = count + 1
    return key
  end, { expr = true, silent = true })
end

-- :Theme <name> switches the colour scheme for this session (the one at startup is koda-glade).
-- koda-<variant>: dark light moss glade. onedark-<style>: dark darker cool deep warm warmer light.
local themes = { "alabaster", "koda-dark", "koda-light", "koda-moss", "koda-glade" }
for _, style in ipairs({ "dark", "darker", "cool", "deep", "warm", "warmer", "light" }) do
  table.insert(themes, "onedark-" .. style)
end
vim.api.nvim_create_user_command("Theme", function(opts)
  local name = opts.args
  local style = name:match("^onedark%-(%a+)$")
  if style then
    vim.opt.background = style == "light" and "light" or "dark"
    require("lazy").load({ plugins = { "onedark.nvim" } })
    require("onedark").setup({ style = style })
    require("onedark").load()
  elseif vim.tbl_contains(themes, name) then
    vim.opt.background = (name == "koda-dark" or name == "koda-moss") and "dark" or "light"
    vim.cmd.colorscheme(name)
  else
    vim.notify("Theme: unknown '" .. name .. "'. Options: " .. table.concat(themes, ", "), vim.log.levels.WARN)
  end
end, {
  nargs = 1,
  complete = function(arg) return vim.tbl_filter(function(t) return t:find(arg, 1, true) == 1 end, themes) end,
  desc = "Switch colour scheme",
})
