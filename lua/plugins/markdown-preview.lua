return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  -- Disable LazyVim's default <leader>cp mapping; use :MarkdownPreviewToggle instead.
  keys = {
    { "<leader>cp", false, ft = "markdown" },
  },
  -- --no-save/--no-package-lock so the build never modifies the plugin's
  -- tracked yarn.lock (otherwise lazy sees "local changes" and refuses to update).
  build = "cd app && npm install --no-save --no-package-lock",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
