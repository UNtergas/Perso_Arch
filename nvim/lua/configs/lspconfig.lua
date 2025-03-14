-- Load NvChad defaults
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"
local navic = require "nvim-navic"

local function custom_on_attach(client, bufnr)
  -- Call NvChad's default on_attach
  if nvlsp.on_attach then
    nvlsp.on_attach(client, bufnr)
  end

  -- Attach nvim-navic if the server supports document symbols
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
    print("nvim-navic attached!") -- Debugging output
  else
    print("nvim-navic not available for this LSP")
  end
end

-- LSP servers with nvim-navic support
local servers = {
  -- Web Development
  "html", "cssls", "ts_ls",

  -- Backend Development
  "pyright", "jdtls", "clangd", "rust_analyzer", "gopls",

  -- Shell & Scripting
  "bashls", "jsonls", "yamlls", "dockerls", "graphql",

  -- System Programming
  "clangd", "cmake",

  -- Markdown & Docs
  "marksman",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = custom_on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }

