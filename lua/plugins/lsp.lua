-- Free up `K` from LazyVim's default LSP hover so our global
-- `K = <C-u>zz` (half-page up) in config/keymaps.lua isn't shadowed
-- by the buffer-local LSP mapping. Hover lives on `gh` instead.
--
-- The default `K` is defined in LazyVim's `servers['*'].keys`, so we
-- disable it the same way: set its rhs to `false` for all servers.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "K", false },
        },
      },
    },
  },
}
