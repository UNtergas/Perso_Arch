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

-- Indentation: 4 spaces by default (easier to read). 2 where the language's convention is 2: TypeScript / JavaScript / JSON
-- (Prettier's default and the projects' tabWidth), HTML / CSS / SCSS / Less, YAML, Ruby, Scala, Dart, Elixir. Go keeps tabs
-- (its filetype plugin). A project's .editorconfig overrides all of this.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "jsonc",
    "html", "css", "scss", "less", "yaml", "ruby", "scala", "dart", "elixir",
  },
  callback = function(ev)
    vim.bo[ev.buf].tabstop, vim.bo[ev.buf].shiftwidth, vim.bo[ev.buf].softtabstop = 2, 2, 2
  end,
})

-- Indent size picker: the "Spaces: 4" segment in the statusline (click it) or SPC t i. It changes the size for every file
-- of this session (nothing is rewritten, only the options change). A buffer whose .editorconfig sets indent_size /
-- indent_style / tab_width is left alone, so a project's .editorconfig always wins.
local function editorconfig_indent(buf)
  local ec = vim.b[buf].editorconfig
  return type(ec) == "table" and (ec.indent_size or ec.indent_style or ec.tab_width) ~= nil
end
local function set_indent(buf, size, tabs)
  vim.bo[buf].tabstop, vim.bo[buf].shiftwidth, vim.bo[buf].softtabstop = size, size, size
  vim.bo[buf].expandtab = not tabs
end
function _G.indent_label()
  local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
  return (vim.bo.expandtab and "Spaces: " or "Tabs: ") .. sw
end
local function each_file_buffer(fn)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == "" and not editorconfig_indent(b) then fn(b) end
  end
end
function _G.indent_apply(size, tabs)
  vim.g.indent_override = { size = size, tabs = tabs }
  vim.go.tabstop, vim.go.shiftwidth, vim.go.softtabstop, vim.go.expandtab = size, size, size, not tabs -- vim.go: global only, a plain :set would also overwrite the current buffer
  each_file_buffer(function(b) set_indent(b, size, tabs) end)
  vim.cmd.redrawstatus()
end
function _G.indent_reset() -- back to the defaults: 4 spaces, 2 for the languages in the FileType rule above, filetype plugins (Go tabs)
  vim.g.indent_override = nil
  vim.go.tabstop, vim.go.shiftwidth, vim.go.softtabstop, vim.go.expandtab = 4, 4, 4, true
  each_file_buffer(function(b)
    vim.api.nvim_buf_call(b, function() -- in the buffer, so the filetype plugins and the TypeScript rule hit this one
      vim.cmd("setlocal tabstop< shiftwidth< softtabstop< expandtab<")
      vim.api.nvim_exec_autocmds("FileType", { buffer = b })
    end)
  end)
  vim.cmd.redrawstatus()
end
function _G.indent_choose()
  local items = {
    { "Spaces: 2", 2, false }, { "Spaces: 4", 4, false }, { "Spaces: 8", 8, false }, { "Tabs: 4", 4, true },
    { "Default (4, web / TS / YAML / Ruby 2)" },
  }
  vim.ui.select(items, {
    prompt = "Indent size (all files, .editorconfig wins)",
    format_item = function(i) return i[1] end,
  }, function(choice)
    if not choice then return end
    if choice[2] then _G.indent_apply(choice[2], choice[3]) else _G.indent_reset() end
  end)
end
vim.api.nvim_create_autocmd("FileType", { -- a picked size also applies to files opened later
  callback = function(ev)
    local o = vim.g.indent_override
    if o and vim.bo[ev.buf].buftype == "" and not editorconfig_indent(ev.buf) then set_indent(ev.buf, o.size, o.tabs) end
  end,
})
vim.keymap.set("n", "<leader>ti", function() _G.indent_choose() end, { desc = "Indent size (spaces / tabs)" })

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
vim.opt.laststatus = 3 -- global statusline (lualine globalstatus = true); set early so the bar does not jump when lualine loads

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
      local koda_glade_bg = 0xfafafa -- was 0xf3f3f3; raised because the window is translucent (niri opacity) and blends with the darker wallpaper
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
          -- selection, multicursor (Ctrl-d) and search matches (* and /): koda's selection #e2eeee is barely darker
          -- than the page (1.07:1). The indent-block bands (ibl, 6 pale tints at 30%) sit within ~25 of the page
          -- colour in Lab, so a pale highlight (the old light blue, the pale yellow) disappears on a band of the
          -- same hue. These yellows stay 40+ (Lab) away from the page and from all six bands, text stays readable.
          --   Visual / MultiCursorVisual (linked) : #ecd860  yellow
          --   Search (every other match of *)      : #eedb72  a little lighter, so the selection still wins
          --   CurSearch / IncSearch (current match): #e8b050  amber, the one you are on
          --   LspReference (word under cursor)     : #e6e6e6  neutral grey, so it never competes with the others
          vim.api.nvim_set_hl(0, "Visual", { bg = 0xecd860 })
          vim.api.nvim_set_hl(0, "Search", { bg = 0xeedb72 })
          vim.api.nvim_set_hl(0, "CurSearch", { bg = 0xe8b050 })
          vim.api.nvim_set_hl(0, "IncSearch", { bg = 0xe8b050 })
          for _, n in ipairs({ "LspReferenceText", "LspReferenceRead", "LspReferenceWrite" }) do
            vim.api.nvim_set_hl(0, n, { bg = 0xe6e6e6 })
          end
          -- comments: Alabaster's light comment red (#aa3731), a little softer (#b04a45, 5.1:1 on the page) instead of koda's grey
          vim.api.nvim_set_hl(0, "Comment", { fg = 0xb04a45 })
          vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
        end,
      })
      vim.cmd.colorscheme("koda-glade")
    end,
  },
  -- active window tracking: the border around the focused window is drawn thick and blue (same blue as the active
  -- tmux pane border). Backgrounds stay as they are. Loads on the first WinLeave, i.e. once there is a split.
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "WinLeave",
    opts = {
      border = "bold",
      colors = { "#4a6a6a" },
      animate = { enabled = false },
      excluded_ft = { "packer", "TelescopePrompt", "mason", "lazy" },
    },
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
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
            direction_priority = {
              menu_north = { "e", "w", "n", "s" },
              menu_south = { "e", "w", "s", "n" },
            },
          },
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
      local function fill_symbol_ranges(result, encoding)
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
            local text = lines and lines[line + 1] or ""
            local start = vim.str_utfindex(text, encoding or "utf-16", col, false)
            loc.range = { start = { line = line, character = start }, ["end"] = { line = line, character = start + vim.str_utfindex(sym.name, encoding or "utf-16") } }
          end
        end
      end
      -- Library sources (kotlin.*, kotlinx.*): the server resolves these imports (hover works) but gives no location
      -- for them, so gd found nothing. Open the declaration from the newest sources jar in Gradle's cache instead
      -- (read-only copy, extracted once under stdpath("cache")/kotlin-sources).
      local gradle_cache = vim.fn.expand((vim.env.GRADLE_USER_HOME or "~/.gradle") .. "/caches/modules-2/files-2.1")
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
      local function library_definition(word, source_buf, encoding)
        local pkg
        for _, text in ipairs(vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)) do
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
                local buf = vim.fn.bufadd(file)
                vim.b[buf].kvim_library_source = true
                vim.fn.bufload(buf)
                vim.bo[buf].modifiable, vim.bo[buf].readonly = false, true
                local character = vim.str_utfindex(lines[line], encoding, col, false)
                return { uri = vim.uri_from_fname(file), range = {
                  start = { line = line - 1, character = character },
                  ["end"] = { line = line - 1, character = character + vim.str_utfindex(word, encoding) },
                } }
              end
            end
          end
        end
      end
      -- Both native gd and Lspsaga gp receive the same augmented definition locations.
      vim.lsp.config("kotlin_language_server", {
        cmd_env = { JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-amd64" },
        root_dir = function(buf, on_dir)
          if vim.b[buf].kvim_library_source then return end
          local markers = vim.lsp.config.kotlin_language_server.root_markers
          on_dir(vim.fs.root(buf, markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(buf)))
        end,
        -- keep the server's symbol index (kls_database.db) out of the projects: a stale one left in a project root
        -- made `gd` fail on top-level functions (isLegacyJWT, getTokenType) while classes still worked
        before_init = function(params)
          -- one folder per project root, so projects never share an index
          local root = type(params.rootPath) == "string" and params.rootPath
            or (type(params.rootUri) == "string" and vim.uri_to_fname(params.rootUri)) or vim.fn.getcwd()
          local dir = vim.fn.stdpath("cache") .. "/kotlin-language-server/" .. vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 8)
          vim.fn.mkdir(dir, "p")
          params.initializationOptions = vim.tbl_extend("force", params.initializationOptions or {}, { storagePath = dir })
        end,
        on_attach = function(client)
          require("kotlin_definition").attach(client, {
            fill_ranges = fill_symbol_ranges,
            library = library_definition,
          })
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
          m("gd", vim.lsp.buf.definition, "Go to definition")
          m("gp", "<cmd>Lspsaga peek_definition<cr>", "Peek definition (Lspsaga)")
          m("gD", vim.lsp.buf.declaration, "Go to declaration")
          m("gr", "<cmd>Lspsaga finder ref<cr>", "Show references (Lspsaga)")
          m("gi", vim.lsp.buf.implementation, "Go to implementation")
          m("K", "<cmd>Lspsaga hover_doc<cr>", "Hover docs (Lspsaga)")
          m("<leader>cr", "<cmd>Lspsaga rename<cr>", "Rename symbol (Lspsaga)")
          m("<leader>ca", function() _G.code_action() end, "Code action", { "n", "v" })
          m("<leader>rn", "<cmd>Lspsaga rename<cr>", "Rename symbol (Lspsaga)")
          m("<leader>d", "<cmd>Lspsaga show_line_diagnostics<cr>", "Line diagnostics (Lspsaga)")
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
        -- C-q still sends Telescope results to the quickfix list.
        mappings = {
          i = {
            ["<C-t>"] = false,
            ["<M-q>"] = "close", -- default is "send to quickfix and open it"; C-q still does that
          },
          n = {
            ["<C-t>"] = false,
            ["<M-q>"] = "close",
          },
        },
      },
    },
  },

  -- Lspsaga: breadcrumbs and focused LSP popups.
  {
    "nvimdev/lspsaga.nvim",
    enabled = not vim.g.vscode,
    lazy = false, -- register symbol tracking before the first LspAttach
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      ui = { border = "rounded" },
      symbol_in_winbar = { enable = true, show_file = true, folder_level = 0 },
      lightbulb = { enable = false }, -- keep git signs and avoid unsolicited action requests
      hover = { max_width = 0.7, max_height = 0.6 },
      rename = { auto_save = false, keys = { quit = "<C-c>" } },
      definition = { keys = { close = "<Esc>" } },
      outline = {
        win_position = "right",
        win_width = 35,
        auto_preview = true,
        close_after_jump = false,
        keys = { toggle_or_jump = "<CR>", jump = "o", quit = { "q", "<Esc>" } },
      },
      finder = {
        default = "ref",
        keys = { toggle_or_open = "<CR>", close = "<Esc>" },
      },
      diagnostic = { keys = { quit = { "q", "<Esc>" } } },
    },
    config = function(_, opts)
      require("lspsaga").setup(opts)
      require("saga_breadcrumb").setup()
      -- Kotlin's first documentSymbol response may be empty while Gradle is indexing.
      -- Preserve the old Dropbar retry window without overlapping outstanding requests.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("KvimSagaSymbolRetry", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "kotlin_language_server" then return end
          local attempts = 0
          local function retry()
            if not vim.api.nvim_buf_is_valid(ev.buf) or not vim.lsp.buf_is_attached(ev.buf, client.id) then return end
            local symbols = require("lspsaga.symbol.head")
            local state = symbols:get_buf_symbols(ev.buf)
            if state and state.symbols and #state.symbols > 0 then return end
            attempts = attempts + 1
            if not state or not state.pending_request then symbols:do_request(ev.buf, client.id) end
            if attempts < 300 then vim.defer_fn(retry, 1000) end
          end
          vim.defer_fn(retry, 1000)
        end,
      })
      -- Finder file headers have four-space indentation; reference rows have six.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("SagaFinderFileNavigation", { clear = true }),
        pattern = "sagafinder",
        callback = function(ev)
          local function jump_file(direction)
            local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
            local row = vim.api.nvim_win_get_cursor(0)[1]
            for _ = 1, vim.v.count1 do
              for next_row = row + direction, direction > 0 and #lines or 1, direction do
                if lines[next_row]:match("^    %S") then
                  row = next_row
                  break
                end
              end
            end
            vim.api.nvim_win_set_cursor(0, { row, 0 })
          end
          vim.keymap.set("n", "]f", function() jump_file(1) end,
            { buffer = ev.buf, desc = "Next reference file" })
          vim.keymap.set("n", "[f", function() jump_file(-1) end,
            { buffer = ev.buf, desc = "Previous reference file" })
        end,
      })

    end,
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

  -- Buffer manager: the open buffers as an editable list (dd closes one, move a line to reorder, Enter or a line number opens)
  {
    "j-morano/buffer_manager.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { short_file_names = true }, -- no order_buffers: the list keeps its order (new buffers go to the end), you reorder it by hand
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
      -- One palette for everything, as in the ibl README's rainbow-delimiters section: the brackets (rainbow-delimiters,
      -- see its spec below), the scope guide and the underline on the opening / closing line all take the colour of the
      -- bracket that opens the scope. ibl draws the underline itself as { underline, sp = guide colour }.
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#d6d6d6" })
        for k, name in ipairs(names) do
          vim.api.nvim_set_hl(0, name, { fg = colors[k] })
        end
      end)
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
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
          -- left one-eighth block: thin, flush with the left edge of its cell, so it meets
          -- the underline on the opening line, which starts at the same column.
          -- ▏ 1/8, ▎ 2/8, ▍ 3/8, ▌ 4/8 of the cell width
          char = "▏",
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
      picker = { enabled = true }, -- also replaces vim.ui.select for code actions with a filterable list
      -- smooth scrolling: any viewport change (Ctrl-J/K half page, search jumps, gg/G, mouse wheel) is animated.
      -- Short on purpose (default total is 250 ms); `vim.g.snacks_scroll = false` turns it off, per buffer: vim.b.snacks_scroll
      scroll = { enabled = true, animate = { duration = { step = 15, total = 60 }, easing = "linear" } },
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
    init = function()
      -- same six groups as the indent guides (IblL1..6, defined in the ibl spec), so a bracket and its scope match
      vim.g.rainbow_delimiters = {
        query = { tsx = "rainbow-parens" },
        highlight = { "IblL1", "IblL2", "IblL3", "IblL4", "IblL5", "IblL6" },
      }
    end,
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
      -- ysw = ysiw, ysW = ysiW (the plain "w" motion only wrapped from the cursor to the next word, rarely wanted)
      vim.keymap.set("n", "ysw", "ysiw", { remap = true, desc = "Surround word" })
      vim.keymap.set("n", "ysW", "ysiW", { remap = true, desc = "Surround WORD" })
    end,
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    init = function() vim.g.undotree_SetFocusWhenToggle = 1 end, -- SPC s u moves the cursor into the tree
  },
  { -- ":" as a floating popup (upper middle). Only the command line: messages, notify and LSP UI stay as they were
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = { enabled = true, view = "cmdline_popup" },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
      },
      views = {
        cmdline_popup = {
          position = { row = "20%", col = "50%" }, -- percentages centre the popup on that point of the screen
          size = { width = "60%", height = 1 },
          border = { style = "rounded", padding = { 0, 1 } },
        },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      -- Notifications stack upward from the bottom-right corner.
      notify.setup({ timeout = 3000, render = "compact", stages = require("notify.stages.fade")(require("notify.stages.util").DIRECTION.BOTTOM_UP), background_colour = "#ededed" })
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
    -- statusline + tabline (encoding > path > git counts ... harpoon slots); no winbar section, Lspsaga owns that.
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
      -- normal mode: a > b > c fade from darkest to lightest (c stays the theme's #cbd6d6)
      theme.normal.a = { fg = "#14201f", bg = "#8da1a1", gui = "bold" }
      theme.normal.b = { fg = "#1c2828", bg = "#adbcbc" }
      -- right side mirrors the left: y (percent) = b shade, z (line:col) = a (project) colour, so it fades c > b > a > language
      for _, m in ipairs({ "normal", "insert", "visual", "replace", "command" }) do
        theme[m].y = theme.normal.b
      end
      -- mode colours of the first section (statusline and tabline): insert = light green, visual = light blue, replace = light yellow,
      -- tints of koda-glade's own string green (#448c27) and function blue (#325cc0), with dark text
      theme.insert.a = { fg = "#1d3a0f", bg = "#b5d99c", gui = "bold" }
      theme.visual.a = { fg = "#1a2f55", bg = "#b8d0f0", gui = "bold" }
      theme.replace.a = { fg = "#4a3800", bg = "#ecd98f", gui = "bold" } -- replace = light yellow (command stays purple)
      for _, m in ipairs({ "normal", "insert", "visual", "replace", "command" }) do theme[m].z = theme[m].a end
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
          globalstatus = true, -- one statusline at the bottom, for the focused window (Lspsaga shows symbol breadcrumbs at the top)
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
          -- right side: macro / search keep the bar colour, then one coloured block per item with a left arrow, fading from light to
          -- dark like the right side of the tmux statusline: lsp > indent > percent > line:col > language
          lualine_x = (function()
            local function block(bg, fg, extra)
              return vim.tbl_extend("force", { separator = { left = "\u{e0b2}" }, padding = { left = 1, right = 1 }, color = { fg = fg, bg = bg } }, extra or {})
            end
            return {
              function() local r = vim.fn.reg_recording() return r == "" and "" or "\u{f111} @" .. r end,
              { "searchcount", maxcount = 999, timeout = 100 },
              block("#b8c7c7", "#1c2828", { "lsp_status", icon = "\u{f085}", symbols = { spinner = {}, done = "", separator = " " } }), -- attached server names
              block("#a3b5b5", "#1c2828", { function() return _G.indent_label() end, on_click = function() _G.indent_choose() end }),
              block("#8da1a1", "#14201f", { "progress" }),
              block("#2f4443", "#e6e6e6", { "location", color = { fg = "#e6e6e6", bg = "#2f4443", gui = "bold" } }),
              block("#14201f", "#e6e6e6", { "filetype", colored = false, fmt = function(s) return s:lower() end, color = { fg = "#e6e6e6", bg = "#14201f", gui = "bold" } }),
            }
          end)(),
          lualine_y = {}, -- lualine fills these with progress / location unless they are set empty: everything is in x
          lualine_z = {},
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
  { -- multiple cursors, live in insert mode (the typing shows at every cursor as you type). Replaces multicursor.nvim below.
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      -- keep VM's own keys, and add the ones from before: Ctrl-d selects the word, again for the next match. Ctrl-Shift-Down / Up
      -- add a cursor below the bottom-most / above the top-most cursor, so the set keeps growing both ways (VM's own
      -- "add cursor" works from the cursor you are on, so Up after Down went nowhere): select the edge region first, then add.
      -- VM maps [ and ] (go to previous / next cursor), which clash with maps in this config: they live on Alt-N / Alt-n.
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Subword Under"] = "<C-d>",
        ["Goto Next"] = "<M-n>",
        ["Goto Prev"] = "<M-N>",
      }
      vim.g.VM_show_warnings = 0
      vim.g.VM_set_statusline = 0 -- VM info goes to the winbar instead (lua/saga_breadcrumb.lua); the statusline stays lualine
      vim.cmd([[
        function! VMAddAtEdge(dir) abort
          if exists('b:VM_Selection') && !empty(b:VM_Selection) && has_key(b:VM_Selection, 'Regions')
            let n = len(b:VM_Selection.Regions)
            if n > 0
              call b:VM_Selection.Global.select_region(a:dir > 0 ? n - 1 : 0)
            endif
          endif
          if a:dir > 0
            call vm#commands#add_cursor_down(0, 1)
          else
            call vm#commands#add_cursor_up(0, 1)
          endif
        endfunction
        nnoremap <silent> <C-S-Down> :<C-u>call VMAddAtEdge(1)<CR>
        nnoremap <silent> <C-S-Up> :<C-u>call VMAddAtEdge(-1)<CR>
      ]])
    end,
  },
  {
    "jake-stewart/multicursor.nvim",
    enabled = false, -- replaced by vim-visual-multi (live insert); the config is kept in case we go back
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      -- ctrl+shift+down / up: add a cursor, like VS Code. Down adds one below the bottom-most cursor, up above the top-most one, so
      -- the set keeps growing both ways (the plugin's own lineAddCursor works from the main cursor, which is the last one
      -- added, so "up" after "down" went nowhere). Then i / a / A / c... act at every cursor.
      local function at_edge(direction, fn)
        mc.action(function(ctx)
          local edge = direction == 1 and ctx:lastCursor() or ctx:firstCursor()
          if edge then edge:select() end
        end)
        fn(direction)
      end
      local function add_cursor(direction) at_edge(direction, mc.lineAddCursor) end
      local function skip_cursor(direction) at_edge(direction, mc.lineSkipCursor) end
      vim.keymap.set({ "n", "x" }, "<C-S-Down>", function() add_cursor(1) end, { desc = "Add cursor below the last one" })
      vim.keymap.set({ "n", "x" }, "<C-S-Up>", function() add_cursor(-1) end, { desc = "Add cursor above the first one" })
      -- Alt-d or SPC m c: cursor mode. While it is on, j / k add a cursor on the line below / above, and J / K move down / up without
      -- adding one (skip a line). Any other key ends the mode and does its normal job, so after the last j just press c, A, i... to
      -- edit at every cursor; SPC m c again ends it quietly; Esc ends it and clears the cursors (the plugin's own Esc).
      -- The mode is a set of buffer-local maps (they win over your global j / k), removed when it ends.
      local mode = { on = false, buf = nil, ns = vim.api.nvim_create_namespace("cursor_mode") }
      local mode_keys = { j = true, k = true, J = true, K = true }
      local function leave_mode()
        if not mode.on then return end
        mode.on = false
        vim.on_key(nil, mode.ns)
        for _, k in ipairs({ "j", "k", "J", "K" }) do pcall(vim.keymap.del, { "n", "x" }, k, { buffer = mode.buf }) end
        vim.api.nvim_echo({ { "" } }, false, {})
      end
      local function toggle_cursor_mode()
        if mode.on then return leave_mode() end
        mode.on, mode.buf = true, vim.api.nvim_get_current_buf()
        local o = { buffer = mode.buf, nowait = true, silent = true }
        local function m(k, fn) vim.keymap.set({ "n", "x" }, k, fn, o) end
        m("j", function() add_cursor(1) end)
        m("k", function() add_cursor(-1) end)
        m("J", function() skip_cursor(1) end)
        m("K", function() skip_cursor(-1) end)
        vim.on_key(function(_, typed)
          if typed ~= "" and not mode_keys[typed] then leave_mode() end
        end, mode.ns)
        vim.api.nvim_echo({ { "-- CURSORS --  j/k add   J/K skip   any other key ends", "ModeMsg" } }, false, {})
      end
      vim.keymap.set("n", "<leader>mc", toggle_cursor_mode, { desc = "Cursor mode (j/k add cursors)" })
      vim.keymap.set("n", "<M-d>", toggle_cursor_mode, { desc = "Cursor mode (j/k add cursors)" }) -- alt+d pairs with ctrl+d (select word / next match)
      -- like VS Code: first press only selects the word under the cursor, then each press adds the next match
      vim.keymap.set("n", "<C-d>", "viw", { desc = "Select word under cursor" })
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

    -- top row of every Oil window: the full path of the folder it shows (read-only; Lspsaga skips Oil buffers).
    -- Evaluated per window (statusline_winid), so splits each show their own folder. %< cuts a too-long path from its left.
    init = function()
      function _G.oil_winbar()
        local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
        local dir = require("oil").get_current_dir(buf)
        local path = dir and vim.fn.fnamemodify(dir, ":~") or vim.api.nvim_buf_get_name(buf) -- trash / ssh: the buffer name
        return "%< \u{f07c} " .. path:gsub("%%", "%%%%")
      end
    end,

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
        -- Alt-Enter: like Enter on a folder, but keeps going down while the folder holds exactly one entry and that
        -- entry is a folder (Java packages: com/application/app). Stops at the first folder with a file, several
        -- entries, or a symlink. Hidden entries count. On a file it is the same as Enter.
        ["<M-CR>"] = {
          desc = "Open folder, descending through single-child folders",
          mode = "n",
          callback = function()
            local oil = require("oil")
            local entry, dir = oil.get_cursor_entry(), oil.get_current_dir()
            if not entry or not dir or entry.type ~= "directory" then return require("oil.actions").select.callback() end
            local path = vim.fs.joinpath(dir, entry.name)
            for _ = 1, 64 do -- bounded, in case of odd trees
              local handle = vim.uv.fs_scandir(path)
              if not handle then break end
              local first, count = nil, 0
              while true do
                local name, kind = vim.uv.fs_scandir_next(handle)
                if not name then break end
                count = count + 1
                if count == 1 then first = { name = name, kind = kind } end
                if count > 1 then break end
              end
              if count ~= 1 or first.kind ~= "directory" then break end
              path = vim.fs.joinpath(path, first.name)
            end
            oil.open(path)
          end,
        },
      },

      win_options = { winbar = "%!v:lua.oil_winbar()" },

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
map({ "n", "v" }, "<C-b>", function() require("buffer_manager.ui").toggle_quick_menu() end, { desc = "Switch buffer" })

-- scroll: <C-d>/<C-f>/<C-b> are taken above, so the native scrolls live on other keys
-- (normal! ignores mappings, so it reaches the built-in <C-d>/<C-u>).
-- Alt-j / Alt-k, not Ctrl-K: Ctrl-K starts the window chords (C-k h/j/k/l, C-k a ...), so a lone Ctrl-K waited a full
-- timeoutlen (1 s) for a second key before it scrolled
map({ "n", "x" }, "<M-j>", [[<Cmd>exe "normal! \<C-d>"<CR>]], { desc = "Half page down" })
map({ "n", "x" }, "<M-k>", [[<Cmd>exe "normal! \<C-u>"<CR>]], { desc = "Half page up" })
-- <PageDown>/<PageUp> are already full-page scroll natively

-- diagnostics / hunks: ]d [d ]g [g
map("n", "]d", function() vim.diagnostic.jump({ count = vim.v.count1, float = false }) end, { desc = "Next diagnostic (no popup)" })
map("n", "[d", function() vim.diagnostic.jump({ count = -vim.v.count1, float = false }) end, { desc = "Prev diagnostic (no popup)" })
map("n", "]g", function() require("gitsigns").nav_hunk("next") end, { desc = "Next hunk" })
map("n", "[g", function() require("gitsigns").nav_hunk("prev") end, { desc = "Prev hunk" })

-- ctrl+alt+arrows: focus window
for key, dir in pairs({ Left = "h", Down = "j", Up = "k", Right = "l" }) do
  map("n", "<C-M-" .. key .. ">", "<C-w>" .. dir, { desc = "Focus window " .. dir })
end

-- ctrl+w q: number every window (big digit in its middle, like tmux's Alt-e q), press the number to jump there; anything else
-- cancels. Windows are numbered left to right, top to bottom. Up to 9 windows.
vim.api.nvim_set_hl(0, "WindowNumber", { fg = "#ffffff", bg = "#4a6a6a", bold = true })
local function pick_window()
  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(w).relative == "" then wins[#wins + 1] = w end
  end
  table.sort(wins, function(a, b)
    local pa, pb = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
    if pa[2] ~= pb[2] then return pa[2] < pb[2] end
    return pa[1] < pb[1]
  end)
  local labels = {}
  for i, w in ipairs(wins) do
    if i > 9 then break end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "       ", "   " .. i .. "   ", "       " })
    local width, height = vim.api.nvim_win_get_width(w), vim.api.nvim_win_get_height(w)
    local label = vim.api.nvim_open_win(buf, false, {
      relative = "win", win = w, width = 7, height = 3, style = "minimal", focusable = false, zindex = 250,
      row = math.max(0, math.floor(height / 2) - 1), col = math.max(0, math.floor(width / 2) - 3),
    })
    vim.wo[label].winhighlight = "Normal:WindowNumber"
    labels[#labels + 1] = label
  end
  vim.cmd("redraw")
  local ok, c = pcall(vim.fn.getcharstr)
  for _, l in ipairs(labels) do pcall(vim.api.nvim_win_close, l, true) end
  local n = ok and tonumber(c)
  if n and wins[n] then vim.api.nvim_set_current_win(wins[n]) end
end
map("n", "<C-w>q", pick_window, { desc = "Number the windows, press a number to jump" })
-- ctrl+w ctrl+w: close buffer, ctrl+w a: close all buffers
map("n", "<C-w><C-w>", function() Snacks.bufdelete() end, { desc = "Close buffer" })
map("n", "<C-w>a", function() Snacks.bufdelete.all() end, { desc = "Close all buffers" })
map("n", "<C-w>T", "<Nop>", { desc = "Disabled: one tab per nvim" })
-- ctrl+w x closes the current split (the buffer stays open); it replaces the window exchange.
map("n", "<C-w>x", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<C-w><C-x>", "<cmd>close<cr>", { desc = "Close split" })
-- like tmux: ctrl+w z zooms the window to the whole screen and back, ctrl+w c fills its column (full height),
-- ctrl+w C fills its row (full width); press again to put the old sizes back
local function window_toggle(key, grow)
  return function()
    local win = vim.api.nvim_get_current_win()
    local saved = vim.w[win][key]
    if saved and saved.n == #vim.api.nvim_tabpage_list_wins(0) then
      vim.cmd(saved.restore)
      vim.w[win][key] = nil
      return
    end
    vim.w[win][key] = { restore = vim.fn.winrestcmd(), n = #vim.api.nvim_tabpage_list_wins(0) }
    vim.cmd(grow)
  end
end
map("n", "<C-w>z", window_toggle("saved_zoom", "wincmd _ | wincmd |"), { desc = "Zoom window (toggle)" })
map("n", "<C-w>c", window_toggle("saved_col", "wincmd _"), { desc = "Window fills its column (toggle)" })
map("n", "<C-w>C", window_toggle("saved_row", "wincmd |"), { desc = "Window fills its row (toggle)" })
-- ; is : (this also makes flash leave ; alone in every mode); f/t repeat: press f/t again, , goes back
map({ "n", "x" }, ";", ":", { desc = "Command line" })

-- ctrl+k chords
local function mk_parent(p)
  local dir = vim.fn.fnamemodify(p, ":h")
  if dir ~= "" and dir ~= "." then vim.fn.mkdir(dir, "p") end
end
local ck = { "n", "v" }
-- C-k arrows move the window
map(ck, "<C-k><Left>", "<C-w>H", { desc = "Move window left" })
map(ck, "<C-k><Down>", "<C-w>J", { desc = "Move window down" })
map(ck, "<C-k><Up>", "<C-w>K", { desc = "Move window up" })
map(ck, "<C-k><Right>", "<C-w>L", { desc = "Move window right" })
-- C-k h/j/k/l resize the window: h narrower, l wider, j shorter, k taller. One step is 10% of the screen (columns for h / l, rows
-- for j / k), so from an even split the sizes land on 50, 40, 30, 20 %. C-k = equalises every window, and again puts the
-- previous sizes back (the saved sizes are dropped when the number of windows changes).
local function resize_step(dir)
  local dw = math.max(1, math.floor(vim.o.columns * 0.10 + 0.5))
  local dh = math.max(1, math.floor((vim.o.lines - vim.o.cmdheight) * 0.10 + 0.5))
  -- The key moves a divider in its direction. A window with a neighbour on the right / below has a divider there, so l / j
  -- grow it and h / k shrink it. The rightmost / bottom-most window only has a divider on its left / top: h / k move that one
  -- left / up, which grows the window, and l / j move it right / down, which shrinks it. (Before, h and k always shrank.)
  local cur = vim.fn.winnr()
  if dir == "h" or dir == "l" then
    local has_right = vim.fn.winnr("l") ~= cur
    if not has_right and vim.fn.winnr("h") == cur then return end -- no divider at all: a resize would only eat the command line
    vim.cmd("vertical resize " .. (((dir == "l") == has_right) and "+" or "-") .. dw)
  else
    local has_below = vim.fn.winnr("j") ~= cur
    if not has_below and vim.fn.winnr("k") == cur then return end
    vim.cmd("resize " .. (((dir == "j") == has_below) and "+" or "-") .. dh)
  end
end
map(ck, "<C-k>h", function() resize_step("h") end, { desc = "Window narrower (10%)" })
map(ck, "<C-k>l", function() resize_step("l") end, { desc = "Window wider (10%)" })
map(ck, "<C-k>j", function() resize_step("j") end, { desc = "Window shorter (10%)" })
map(ck, "<C-k>k", function() resize_step("k") end, { desc = "Window taller (10%)" })
map(ck, "<C-k>=", function()
  local saved = vim.t.equal_saved
  if saved and saved.n == #vim.api.nvim_tabpage_list_wins(0) then
    vim.cmd(saved.cmd)
    vim.t.equal_saved = nil
  else
    vim.t.equal_saved = { n = #vim.api.nvim_tabpage_list_wins(0), cmd = vim.fn.winrestcmd() }
    vim.cmd("wincmd =")
  end
end, { desc = "Equal window sizes (again: back to the previous sizes)" })
-- C-k r: resize mode, like i3. h / j / k / l resize the window in 10% steps (same as C-k h/j/k/l), = equal sizes (no toggle back),
-- Esc / Enter / q leave; any other key leaves too.
map(ck, "<C-k>r", function()
  local function status()
    vim.api.nvim_echo({ { "-- RESIZE --  h/j/k/l resize   = equal   Esc/Enter/q done", "ModeMsg" } }, false, {})
  end
  status()
  while true do
    local ok, c = pcall(vim.fn.getcharstr)
    if not ok then break end
    if c == "h" or c == "j" or c == "k" or c == "l" then resize_step(c)
    elseif c == "=" then vim.cmd("wincmd =")
    else break end
    -- colorful-winsep redraws its focus border on WinResized, which does not fire while this loop waits for a key, so the old
    -- border stayed behind until the mode ended: draw it by hand after every step
    pcall(function() require("colorful-winsep.view").render() end)
    vim.cmd("redraw")
    status()
  end
  vim.api.nvim_echo({ { "" } }, false, {})
end, { desc = "Resize mode (h/j/k/l, = equal, Esc)" })
-- C-w \ splits side by side, C-w - splits stacked (like tmux: \ side by side, - stacked)
map("n", "<C-w>\\", "<cmd>rightbelow vsplit<cr>", { desc = "Split side by side" })
map("n", "<C-w>-", "<cmd>rightbelow split<cr>", { desc = "Split stacked" })
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
map("n", "<leader>,", function() require("buffer_manager.ui").toggle_quick_menu() end, { desc = "Switch buffer" })
map("n", "<leader>:", tb("commands"), { desc = "Command palette" })
map("n", "<leader>ss", tb("current_buffer_fuzzy_find"), { desc = "Search lines in buffer" })
map("n", "<leader>sp", tb("live_grep"), { desc = "Search project" })
map("n", "<leader>sw", function()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").live_grep({ default_text = "\\b" .. word .. "\\b", prompt_title = "Whole word: " .. word })
end, { desc = "Search word under cursor (whole word)" })
map("n", "<leader>su", "<cmd>UndotreeToggle<cr>", { desc = "Undo tree" })
map("n", "<leader>bb", function() require("buffer_manager.ui").toggle_quick_menu() end, { desc = "Switch buffer" })
map("n", "<leader>bS", "<cmd>wall<cr>", { desc = "Save all buffers" })
map("n", "<leader>fR", function() Snacks.rename.rename_file() end, { desc = "Rename file (updates imports)" })
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format (manual)" })
-- SPC c x: Lspsaga workspace diagnostics.
-- SPC c X: the same diagnostics in a flat Telescope list.
map("n", "<leader>cx", "<cmd>Lspsaga show_workspace_diagnostics<cr>", { desc = "Diagnostics (Lspsaga)" })
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

-- no snacks smooth-scroll in Oil: resizing the window (terminal split opens/closes) while its animation state is
-- stale made the viewport fight the cursor (stuck, flicker back down). Oil lists are short, scroll jumps are fine.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(a) vim.b[a.buf].snacks_scroll = false end,
})

-- terminal: toggle a bottom terminal, 35% of the screen high (keeps its shell alive when hidden)
local term = { buf = nil, win = nil }
local function toggle_term()
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    term.win = nil
    return
  end
  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.35)) -- 35% of the screen
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

-- Alt-q (or SPC q): close the popups (quickfix, help, grug-far, undo tree, floats, bottom terminal), keep the files
local popup_ft = { qf = true, help = true, checkhealth = true, ["grug-far"] = true, ["grug-far-history"] = true }
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
    -- closing one popup can take others with it (a results panel can close its preview float), so the window
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

-- alt+. = code action (Ctrl-. is not used: tmux does not pass it on)
-- Hide disabled refactorings; the native action list is displayed through Snacks.
function _G.code_action()
  vim.lsp.buf.code_action({ filter = function(action) return not action.disabled end })
end
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
      vim.bo[view].buflisted = false -- keep it out of the buffer switcher: picking a wiped glow view re-runs it as a new terminal
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
-- VSCode-style keys, kept alongside the SPC ones
map("n", "<C-t>", tb("lsp_dynamic_workspace_symbols"), { desc = "Find symbol in workspace" })
-- Ctrl+V pastes from the system clipboard in insert mode only (elsewhere it keeps its default)
map("i", "<C-v>", "<C-r><C-p>+", { desc = "Paste" })
map("n", "<C-S-t>", tb("lsp_document_symbols"), { desc = "Find symbol in this file" })
map("n", "<leader>so", "<cmd>Lspsaga outline<cr>", { desc = "Document outline tree" })

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

-- SPC h r / :Reload: apply config changes without closing. lazy.nvim does not support re-sourcing init.lua, so this saves
-- everything, writes a session, and restarts nvim (:restart, nvim 0.12+) into that session: same files, windows and
-- cursor, fresh config. It stops if a buffer cannot be saved or a terminal job is still running (nothing is lost then).
local function reload_config()
  local session = vim.fn.stdpath("state") .. "/reload-session.vim"
  local ok, err = pcall(function()
    vim.cmd("wall")
    vim.cmd("mksession! " .. vim.fn.fnameescape(session))
    vim.cmd("restart source " .. vim.fn.fnameescape(session))
  end)
  if not ok then vim.notify("Reload cancelled: " .. tostring(err), vim.log.levels.WARN) end
end
map("n", "<leader>hr", reload_config, { desc = "Reload the config (restart, keep the session)" })
vim.api.nvim_create_user_command("Reload", reload_config, { desc = "Reload the config (restart, keep the session)" })

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
-- the file path and symbol breadcrumb live in the winbar (Lspsaga), so the statusline
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
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#d3dcdc" }) -- inactive window dividers: light grey, so the active teal one stands out
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
-- The row under it is Lspsaga's symbol breadcrumb.
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

-- cowboy: after LIMIT hjkl/arrow/+/- presses in a row (each less than GAP ms after the previous one, no count), the key is
-- blocked. Blocked presses count as activity, so holding a key stays blocked until you let go for GAP ms; there is no
-- periodic release. Use w b f t / } instead. A count (5j) resets it; nofile buffers (Oil, pickers) are exempt.
local LIMIT, GAP = 8, 300
for _, key in ipairs({ "h", "j", "k", "l", "+", "-", "<Left>", "<Down>", "<Up>", "<Right>" }) do
  local count, last = 0, 0
  vim.keymap.set("n", key, function()
    local now = vim.uv.now()
    if vim.v.count > 0 or now - last > GAP then count = 0 end
    last = now
    if count >= LIMIT and vim.bo.buftype ~= "nofile" then
      -- expr maps run under textlock: nvim-notify opens a window, so defer it
      vim.schedule(function() vim.notify("Hold it Cowboy! 🤠", vim.log.levels.WARN, { icon = "🤠", id = "cowboy" }) end)
      return ""
    end
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
