-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Homerow half-page scrolling (recenter after each jump).
-- Shadows default J (join) and K (LSP hover / keyword help), remapped below.
vim.keymap.set({ "n", "v" }, "J", "<C-d>zz", { desc = "Half-page down" })
vim.keymap.set({ "n", "v" }, "K", "<C-u>zz", { desc = "Half-page up" })

-- Homerow line start/end (capital h/l = "big" version of left/right).
-- Shadows default H/L (top/bottom of screen).
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Start of line (first non-blank)" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "End of line" })

-- Exit insert mode fast without reaching for Esc.
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Copy the current file's path to the system clipboard.
vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })
vim.keymap.set("n", "<leader>cP", function()
  vim.fn.setreg("+", vim.fn.expand("%:p:h"))
  vim.notify("Copied: " .. vim.fn.expand("%:p:h"))
end, { desc = "Copy folder path" })

-- Exit terminal-mode with a double-esc in ALL terminals (snacks only maps
-- this in its own terminals; plain :terminal buffers were missing it).
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- One global terminal on <C-/> instead of LazyVim's per-project-root ones
-- (no cwd in the key, so every buffer reaches the same shell).
-- Counts still work: 2<C-/> is a second global terminal.
vim.keymap.set({ "n", "t" }, "<c-/>", function()
  Snacks.terminal.focus()
end, { desc = "Terminal (global)" })
vim.keymap.set({ "n", "t" }, "<c-_>", function()
  Snacks.terminal.focus()
end, { desc = "which_key_ignore" })

-- Open a PDF in sioyek (installed unsigned from GitHub releases; the brew
-- cask is disabled, so it lives at /Applications/sioyek.app directly).
-- Current buffer if it's a PDF, else the path under the cursor — so it works
-- both from a snacks PDF preview and from a markdown/LaTeX link to a PDF.
vim.keymap.set("n", "<leader>op", function()
  local target = vim.api.nvim_buf_get_name(0)
  if not target:match("%.pdf$") then
    local cfile = vim.fn.expand("<cfile>")
    target = vim.fn.fnamemodify(vim.fn.expand("%:p:h") .. "/" .. cfile, ":p")
    if not cfile:match("%.pdf$") or vim.fn.filereadable(target) == 0 then
      vim.notify("No PDF here (buffer or under cursor)", vim.log.levels.WARN)
      return
    end
  end
  vim.system({ "open", "-a", "/Applications/sioyek.app", target })
end, { desc = "Open PDF in sioyek" })

-- Rehome the shadowed defaults:
vim.keymap.set("n", "<leader>j", "J", { desc = "Join lines" })
vim.keymap.set("n", "gh", function()
  vim.lsp.buf.hover()
end, { desc = "Hover (keyword help)" })
