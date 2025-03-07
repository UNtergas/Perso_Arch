require "nvchad.mappings"

-- add yours here


local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local telescope = require("telescope.builtin")


-- Unbind default Go to Tag mappings
pcall(vim.keymap.del, "n", "<C-]>")
pcall(vim.keymap.del, "n", "<C-[>")
-- Indent in Visual Mode
map("v", "<C-[>", "<gv", { desc = "Unindent (Visual Mode)" }) -- Shift left and reselect
map("v", "<C-]>", ">gv", { desc = "Indent (Visual Mode)" })   -- Shift right and reselect

-- Indent in Insert Mode
map("i", "<C-[>", "<C-o><<", { desc = "Unindent (Insert Mode)" }) -- Shift left
map("i", "<C-]>", "<C-o>>>", { desc = "Indent (Insert Mode)" })   -- Shift right

-- Ensure Esc (`<C-[>`) still works to exit modes
map("i", "<Esc>", "<Esc>", { desc = "Exit Insert Mode" })
map("v", "<Esc>", "<Esc>", { desc = "Exit Visual Mode" })

-- Quick bind for telescope find 
map("n", "<C-p>", telescope.find_files, { desc = "Find Files (Telescope)" })
-- Show diagnostics on the current line with Alt + d
map("n", "<A-,>", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, opts)
-- Open the TODO list with Telescope
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", opts)

-- Jump between TODOs in the current file
map("n", "]t", function() require("todo-comments").jump_next() end, opts)
map("n", "[t", function() require("todo-comments").jump_prev() end, opts)

map("n", "<Esc>", function()
  local api = require("nvim-tree.api")
  if vim.bo.filetype == "NvimTree" then
    api.tree.close()  -- Close NvimTree if inside
  else
    vim.cmd("nohlsearch") -- Otherwise, clear search highlights
  end
end, opts)

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
