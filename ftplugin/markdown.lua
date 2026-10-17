-- Notebook support in markdown buffers (jupytext converts .ipynb to markdown,
-- so this covers notebooks too).

-- otter LSP inside code cells; pcall because quarto is lazy-loaded on ft and
-- load order vs. ftplugin sourcing isn't guaranteed
local ok, quarto = pcall(require, "quarto")
if ok then
  quarto.activate()
end

-- Code-cell textobjects/motions from after/queries/markdown/textobjects.scm.
-- nvim-treesitter-textobjects main branch has no configs.setup() keymap table;
-- keymaps call its modules directly. Buffer-local so ]b/[b/ib/ab only exist here.
local map = function(mode, lhs, mod, fn, query, desc)
  vim.keymap.set(mode, lhs, function()
    require("nvim-treesitter-textobjects." .. mod)[fn](query, "textobjects")
  end, { buffer = true, silent = true, desc = desc })
end

map({ "n", "x", "o" }, "]b", "move", "goto_next_start", "@code_cell.inner", "next code cell")
map({ "n", "x", "o" }, "[b", "move", "goto_previous_start", "@code_cell.inner", "previous code cell")
map({ "x", "o" }, "ib", "select", "select_textobject", "@code_cell.inner", "in code cell")
map({ "x", "o" }, "ab", "select", "select_textobject", "@code_cell.outer", "around code cell")
map("n", "<leader>sbl", "swap", "swap_next", "@code_cell.outer", "swap cell with next")
map("n", "<leader>sbh", "swap", "swap_previous", "@code_cell.outer", "swap cell with previous")
