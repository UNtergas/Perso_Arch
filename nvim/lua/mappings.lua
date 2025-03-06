require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

local opts = { noremap = true, silent = true }
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- Unbind existing Alt+h and Alt+v terminal mappings
map("n", "<A-h>", "<Nop>", opts)
map("n", "<A-v>", "<Nop>", opts)

-- Resize window using Alt+h/j/k/l
map("n", "<A-j>", "<cmd>resize -2<CR>", opts)   -- Decrease height
map("n", "<A-k>", "<cmd>resize +2<CR>", opts)   -- Increase height
map("n", "<A-h>", "<cmd>vertical resize -2<CR>", opts)  -- Decrease width
map("n", "<A-l>", "<cmd>vertical resize +2<CR>", opts)  -- Increase width


-- 6. Move line(s) up/down with Alt+Up and Alt+Down
map("n", "<A-Up>", "<cmd>m .-2<CR>==", opts)
map("n", "<A-Down>", "<cmd>m .+1<CR>==", opts)
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)
