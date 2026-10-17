-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus"

-- Python tooling: read by LazyVim's python extra (must be set before plugins load)
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- molten-nvim's remote plugin needs a python with pynvim + jupyter_client;
-- pin it so it doesn't drift with whatever env is active in the shell
vim.g.python3_host_prog = vim.fn.expand("~/anaconda3/bin/python")
