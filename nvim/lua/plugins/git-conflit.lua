return {
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Gvdiffsplit", "Gwrite", "Gdiffsplit", "Gcommit" },
    keys = {
      -- { "<leader>gs", "<cmd>G<CR>", desc = "Git status (Fugitive)" },
      { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Git diff (Vertical split)" },
      { "<leader>gl", "<cmd>diffget LOCAL<CR>", desc = "Choose LOCAL version" },
      { "<leader>gr", "<cmd>diffget REMOTE<CR>", desc = "Choose REMOTE version" },
      { "<leader>gc", "<cmd>G commit<CR>", desc = "Git commit" },
      { "<leader>ga", "<cmd>Gwrite<CR>", desc = "Git add current file" },
    },
  },
}
