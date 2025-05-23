require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local telescope = require("telescope.builtin")


-- Disable Ctrl+x in terminal mode
map("t", "<C-x>", "<Nop>", { desc = "Disable Ctrl+x in terminal" })
-- ------- NEO tree selection
-- -- Toggle
-- map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
-- map("n", "<leader>o", "<cmd>Neotree focus<CR>", { desc = "Focus Neo-tree" })
-- --  Toggle Neo-tree with C-n
-- map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })


-- Git: Show file history in command line
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "Git File History (Diffview)" })

-- Git: Show file history in a popup and open with Gedit
map("n", "<leader>gf", function()
  telescope.git_bcommits({
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local entry = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        if entry and entry.value then
          vim.cmd("Gedit " .. entry.value .. ":%")
        end
      end)
      return true
    end,
  })
end, { desc = "View File History and Open with Gedit" })

--- Section for Trouble
-- 🚀 Bind Ctrl+Space to Toggle Trouble Document Symbols
map("n", "<C-Space>", "<cmd>Trouble symbols toggle focus=true<CR>", { desc = "Toggle Trouble Symbols" })

map("n", "<A-/>","<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>", {desc ="Toggle Buffer Diagnostics"})
-- 🚀 Bind Ctrl+/ to Toggle Trouble LSP References
map("n", "<C-_>", "<cmd>Trouble lsp toggle focus=true win.position=bottom win.size= 0.35 <CR>", { desc = "Toggle Trouble LSP References" })
-- end 


-- 🚀 Bind shift-alt-t to open a new terminal in new tab
map("n", "<S-A-t>", "<cmd>tabnew | terminal<CR>", { desc = "Open Terminal in a New Tab" })
-- 🚀 Bind alt-t to open a new tab
map("n", "<A-v>", "<cmd>tabnew<CR>", { desc = "Open a New Tab" })

-- 🚀 Search Symbols in the Entire Workspace
map("n", "<leader>fs", telescope.lsp_workspace_symbols, { desc = "Find Symbols in Workspace" })
map("n", "<C-t>", telescope.lsp_workspace_symbols, { desc = "Find Symbols in Workspace" })

--  Escape Clear Search Highlights
map("n", "<Esc>", function()
    vim.cmd("nohlsearch") -- Otherwise, clear search highlights
end, opts)


--  Bind <C-g> to Telescope Live Grep
map("n", "<C-g>", telescope.live_grep, { desc = "Live Grep (Telescope)" })

-- Bind <C-f> to search within the current buffer
map("n", "<C-f>", telescope.current_buffer_fuzzy_find, { desc = "Find in Current Buffer (Telescope)" })

-- Move view up/down while keeping cursor position
map("n", "<C-Up>", "<C-y>", opts)   -- Move view up
map("n", "<C-Down>", "<C-e>", opts) -- Move view down


-- Select the current word with Alt+y
map("n", "<M-y>", "viw", { desc = "Select Current Word" })

-- Disable the default Ctrl+Z (suspend)
map("n", "<C-z>", "<Nop>", { desc = "Disable Suspend" })

-- Remap Ctrl+Z to Undo in Insert Mode
map("i", "<C-z>", "<C-o>u", { desc = "Undo in Insert Mode" })

-- Remap Ctrl+Z to Undo in Normal Mode
map("n", "<C-z>", "u", { desc = "Undo" })

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

-- Move line(s) up/down with Ctrl+Alt+K and Ctrl+Alt+J
map("n", "<C-A-k>", "<cmd>m .-2<CR>==", opts)
map("n", "<C-A-j>", "<cmd>m .+1<CR>==", opts)
map("v", "<C-A-k>", ":m '<-2<CR>gv=gv", opts)
map("v", "<C-A-j>", ":m '>+1<CR>gv=gv", opts)

-- Vertical split with Ctrl + \
map("n", "<C-\\>", "<cmd>vsplit<CR>", opts)

-- Horizontal split with Ctrl + Alt + \
map("n", "<C-M-\\>", "<cmd>split<CR>", opts)

-- Move buffer to respective window using Ctrl + Alt + Arrow keys
map("n", "<C-M-Up>", "<cmd>wincmd K<CR>", opts)    -- Move to top window
map("n", "<C-M-Down>", "<cmd>wincmd J<CR>", opts)  -- Move to bottom window
map("n", "<C-M-Left>", "<cmd>wincmd H<CR>", opts)  -- Move to left window
map("n", "<C-M-Right>", "<cmd>wincmd L<CR>", opts) -- Move to right window

-- Map <M-e> (Alt + e) to escape terminal mode
map("t", "<M-e>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- Map <Alt-left/right> in insert mode to jump word
map("i", "<M-d>", "<Esc>ea", { desc = "Move forward one word in insert mode" })
map("i", "<M-a>", "<Esc>bi", { desc = "Move backward one word in insert mode" })

