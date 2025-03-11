require "nvchad.mappings"

-- add yours here


local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local telescope = require("telescope.builtin")


--- Section for Trouble
-- 🚀 Bind Ctrl+Space to Toggle Trouble Document Symbols
map("n", "<C-Space>", "<cmd>Trouble symbols toggle focus=true<CR>", { desc = "Toggle Trouble Symbols" })

-- 🚀 Bind Ctrl+M to Toggle Trouble LSP References
map("n", "<C-m>", "<cmd>Trouble lsp toggle focus=true win.position=left win.size= 0.4 <CR>", { desc = "Toggle Trouble LSP References" })

-- 🚀 Bind Ctrl+V to open a new tab
map("n", "<C-v>", "<cmd>tabnew<CR>", { desc = "Open a New Tab" })

-- end 


-- 🚀 Search Symbols in the Entire Workspace
map("n", "<leader>fs", telescope.lsp_workspace_symbols, { desc = "Find Symbols in Workspace" })
map("n", "<C-t>", telescope.lsp_workspace_symbols, { desc = "Find Symbols in Workspace" })

-- NEO tree selection
--
-- Toggle
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
map("n", "<leader>o", "<cmd>Neotree focus<CR>", { desc = "Focus Neo-tree" })

--  Toggle Neo-tree with C-n
map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

--  Escape Clear Search Highlights
map("n", "<Esc>", function()
    vim.cmd("nohlsearch") -- Otherwise, clear search highlights
end, opts)

--  Bind <C-f> to Telescope Live Grep
map("n", "<C-f>", telescope.live_grep, { desc = "Live Grep (Telescope)" })


-- Mouse support: Open menu on right-click
vim.keymap.set({ "n", "v" }, "<RightMouse>", function()
  require('menu.utils').delete_old_menus()

  vim.cmd.exec '"normal! \\<RightMouse>"'

  -- Determine the menu options based on buffer type
  local buf = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
  local options = vim.bo[buf].ft == "NvimTree" and "nvimtree" or "default"

  require("menu").open(options, { mouse = true })
end, { desc = "Open menu on right-click" })

-- Select the current word with Ctrl+y
map("n", "<C-y>", "viw", { desc = "Select Current Word" })

-- Disable the default Ctrl+Z (suspend)
map("n", "<C-z>", "<Nop>", { desc = "Disable Suspend" })

-- Remap Ctrl+Z to Undo in Insert Mode
map("i", "<C-z>", "<C-o>u", { desc = "Undo in Insert Mode" })

-- Remap Ctrl+Z to Undo in Normal Mode
map("n", "<C-z>", "u", { desc = "Undo" })

-- Move view up/down while keeping cursor position
map("n", "<C-Up>", "<C-y>", opts)   -- Move view up
map("n", "<C-Down>", "<C-e>", opts) -- Move view down

-- Unbind default Alt-p and Alt-o
pcall(vim.keymap.del, "n", "<A-p>")
pcall(vim.keymap.del, "n", "<A-o>")

-- ✅ Indent in Visual Mode (Fix: Keeps selection)
map("v", "<A-o>", "<gv", { desc = "Unindent (Visual Mode)" }) -- Shift left and reselect
map("v", "<A-p>", ">gv", { desc = "Indent (Visual Mode)" })   -- Shift right and reselect

-- ✅ Indent in Insert Mode (Fix: Stays in insert mode)
map("i", "<A-o>", "<Esc><<i", { desc = "Unindent (Insert Mode)" }) -- Shift left, return to insert mode
map("i", "<A-p>", "<Esc>>i", { desc = "Indent (Insert Mode)" })    -- Shift right, return to insert mode

-- ✅ Indent in Normal Mode (Optional: Also works in normal mode)
map("n", "<A-o>", "<<", { desc = "Unindent (Normal Mode)" }) -- Shift left
map("n", "<A-p>", ">>", { desc = "Indent (Normal Mode)" })   -- Shift right

-- Close the current buffer
map("n", "<C-q>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

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

-- map("n", "<Esc>", function()
--   local api = require("nvim-tree.api")
--   if vim.bo.filetype == "NvimTree" then
--     api.tree.close()  -- Close NvimTree if inside
--   else
--     vim.cmd("nohlsearch") -- Otherwise, clear search highlights
--   end
-- end, opts)

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

-- -- Toggle Symbols Outline with both Ctrl + Space and Leader + so
-- map("n", "<C-Space>", ":SymbolsOutline<CR>", { desc = "Toggle outline symbol" }, opts)
-- map("n", "<leader>so", ":SymbolsOutline<CR>", { desc = "Toggle outline symbol" }, opts)
-- Vertical split with Ctrl + \
map("n", "<C-\\>", "<cmd>vsplit<CR>", opts)

-- Horizontal split with Ctrl + Alt + \
map("n", "<C-M-\\>", "<cmd>split<CR>", opts)

-- Move buffer to respective window using Ctrl + Alt + Arrow keys
map("n", "<C-M-Up>", "<cmd>wincmd K<CR>", opts)    -- Move to top window
map("n", "<C-M-Down>", "<cmd>wincmd J<CR>", opts)  -- Move to bottom window
map("n", "<C-M-Left>", "<cmd>wincmd H<CR>", opts)  -- Move to left window
map("n", "<C-M-Right>", "<cmd>wincmd L<CR>", opts) -- Move to right window
