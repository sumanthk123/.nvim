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
  vim.fn.setreg("+", vim.fn.expand("%"))
  vim.notify("Copied: " .. vim.fn.expand("%"))
end, { desc = "Copy relative file path" })

-- Rehome the shadowed defaults:
vim.keymap.set("n", "<leader>j", "J", { desc = "Join lines" })
vim.keymap.set("n", "gh", function()
  vim.lsp.buf.hover()
end, { desc = "Hover (keyword help)" })
