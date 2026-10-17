-- Free up `K` from LazyVim's default LSP hover so our global
-- `K = <C-u>zz` (half-page up) in config/keymaps.lua isn't shadowed
-- by the buffer-local LSP mapping. Hover lives on `gh` instead.
--
-- The default `K` is defined in LazyVim's `servers['*'].keys`, so we
-- disable it the same way: set its rhs to `false` for all servers.
return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Full diagnostic text for the cursor line as wrapped virtual lines below
    -- it (inline virtual text clips at the window edge); other lines keep the
    -- short inline hint. Only ERROR severity is displayed inline — warnings
    -- (yellow) stay out of sight but remain listed in Trouble (<leader>xx).
    diagnostics = {
      virtual_text = {
        current_line = false,
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      virtual_lines = {
        current_line = true,
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      underline = { severity = { min = vim.diagnostic.severity.ERROR } },
      signs = { severity = { min = vim.diagnostic.severity.ERROR } },
    },
    servers = {
      ["*"] = {
        keys = {
          { "K", false },
        },
      },
      -- OCaml LSP from the opam switch (per https://ocaml.org/docs/set-up-editor):
      -- ocaml-lsp-server is version-sensitive, so use the opam-installed binary
      -- rather than Mason's.
      ocamllsp = {
        mason = false,
      },
    },
  },
}
