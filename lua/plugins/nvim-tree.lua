-- Use nvim-tree as the file explorer instead of LazyVim's default neo-tree.
return {
  -- Disable the neo-tree that LazyVim enables by default.
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer (nvim-tree)" },
      { "<leader>o", "<cmd>NvimTreeFocus<cr>", desc = "Explorer: focus tree" },
      { "<leader>fe", "<cmd>NvimTreeFindFile<cr>", desc = "Explorer: reveal current file" },
    },
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 35 },
      renderer = { group_empty = true },
      filters = {
        dotfiles = false,
        git_ignored = false, -- show git-ignored files (otherwise folders look "empty")
      },
      update_focused_file = { enable = true }, -- highlight the current buffer in the tree
      actions = {
        open_file = {
          -- when >1 window is open, label each pane and let you pick where the file lands
          window_picker = {
            enable = true,
            chars = "ASDFJKL", -- letters shown on each window; press one to choose
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end,
  },
}
