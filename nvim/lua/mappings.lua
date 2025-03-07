require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Close NvimTree with Esc only if the cursor is inside the tree window
map("n", "<Esc>", function()
  local api = require("nvim-tree.api")
  if vim.bo.filetype == "NvimTree" then
    api.tree.close()
  end
end, opts)
vim.api.nvim_set_keymap("n", "<Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
-- Code action keymap (Ctrl + .)
map("n", "<A-.>", vim.lsp.buf.code_action, opts)
map("v", "<A-.>", vim.lsp.buf.code_action, opts) -- Enable for visual mode too

-- Command mode shortcut
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Escape insert mode with 'jk'
map("i", "jk", "<ESC>")

-- Unbind existing Alt+h and Alt+v terminal mappings
map("n", "<A-h>", "<Nop>", opts)
map("n", "<A-v>", "<Nop>", opts)

-- Resize window using Alt+h/j/k/l
map("n", "<A-j>", "<cmd>resize -2<CR>", opts)   -- Decrease height
map("n", "<A-k>", "<cmd>resize +2<CR>", opts)   -- Increase height
map("n", "<A-h>", "<cmd>vertical resize -2<CR>", opts)  -- Decrease width
map("n", "<A-l>", "<cmd>vertical resize +2<CR>", opts)  -- Increase width

-- Switch between buffers with Alt+number
for i = 1, 9, 1 do
  vim.keymap.set("n", string.format("<A-%s>", i), function()
    vim.api.nvim_set_current_buf(vim.t.bufs[i])
  end)
end

-- Move line(s) up/down with Alt+Up and Alt+Down
map("n", "<A-Up>", "<cmd>m .-2<CR>==", opts)
map("n", "<A-Down>", "<cmd>m .+1<CR>==", opts)
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)

-- === ADDED KEYMAPS ===

-- Vertical split with Ctrl + \
map("n", "<C-\\>", "<cmd>vsplit<CR>", opts)

-- Horizontal split with Ctrl + Alt + \
map("n", "<C-M-\\>", "<cmd>split<CR>", opts)

-- Move buffer to respective window using Ctrl + Alt + Arrow keys
map("n", "<C-M-Up>", "<cmd>wincmd K<CR>", opts)    -- Move to top window
map("n", "<C-M-Down>", "<cmd>wincmd J<CR>", opts)  -- Move to bottom window
map("n", "<C-M-Left>", "<cmd>wincmd H<CR>", opts)  -- Move to left window
map("n", "<C-M-Right>", "<cmd>wincmd L<CR>", opts) -- Move to right window
