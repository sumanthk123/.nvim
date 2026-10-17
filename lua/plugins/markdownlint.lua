-- nvim-lint pipes the buffer to markdownlint-cli2 over stdin, so the linter
-- resolves its config from nvim's cwd (unreliable) and never finds a home-level
-- config. Force it to always use the global ~/.markdownlint.jsonc so the rule
-- set (notably MD013 line-length disabled) applies to every markdown file.
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", vim.fn.expand("~/.markdownlint.jsonc"), "-" },
      },
    },
  },
}
