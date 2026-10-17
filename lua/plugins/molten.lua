-- Jupyter notebooks in Neovim, per https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md
-- Pieces: molten (kernel + outputs), jupytext (.ipynb <-> markdown), quarto+otter
-- (LSP inside code cells), image.nvim (plot rendering via Ghostty's kitty
-- graphics protocol; needs the `magick` CLI from brew's imagemagick).
-- Python deps live in anaconda base: pynvim, jupyter_client, jupytext, nbformat.
return {
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      -- molten output images only; markdown/neorg inline images stay with
      -- snacks.nvim (image.lua) so the two don't double-render
      integrations = {},
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    lazy = false, -- remote plugin + ipynb autocmds need to be live at startup
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    config = function()
      local map = vim.keymap.set
      map("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
      map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
      map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
      map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true })
      map("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
      map("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
      map("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })

      -- On opening a .ipynb: start the kernel it was saved with (fall back to the
      -- active venv/conda env) and pull its saved outputs into molten.
      local imb = function(e)
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()
          local try_kernel_name = function()
            local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
            return metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)
          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
            if venv ~= nil then
              kernel_name = string.match(venv, "/.+/(.+)")
            end
          end
          if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(("MoltenInit %s"):format(kernel_name))
          end
          vim.cmd("MoltenImportOutput")
        end)
      end

      vim.api.nvim_create_autocmd("BufAdd", {
        pattern = { "*.ipynb" },
        callback = imb,
      })
      -- for notebooks opened directly on the command line (BufAdd won't fire)
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.ipynb" },
        callback = function(e)
          if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
            imb(e)
          end
        end,
      })

      -- keep outputs saved inside the .ipynb on write
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.ipynb" },
        callback = function()
          if require("molten.status").initialized() == "Molten" then
            vim.cmd("MoltenExportOutput!")
          end
        end,
      })

      -- virt-text output placement only makes sense inside markdown code fences;
      -- plain .py buffers get float-style output instead
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.py",
        callback = function(e)
          if string.match(e.file, ".otter.") then
            return
          end
          if require("molten.status").initialized() == "Molten" then
            vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
            vim.fn.MoltenUpdateOption("virt_text_output", false)
          else
            vim.g.molten_virt_lines_off_by_1 = false
            vim.g.molten_virt_text_output = false
          end
        end,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.qmd", "*.md", "*.ipynb" },
        callback = function(e)
          if string.match(e.file, ".otter.") then
            return
          end
          if require("molten.status").initialized() == "Molten" then
            vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
            vim.fn.MoltenUpdateOption("virt_text_output", true)
          else
            vim.g.molten_virt_lines_off_by_1 = true
            vim.g.molten_virt_text_output = true
          end
        end,
      })

      -- :NewNotebook path/name — create a minimal .ipynb (jupytext needs valid
      -- notebook JSON to open a file, so touch/edit alone can't do this)
      local default_notebook = [[
        {
          "cells": [
           {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
              ""
            ]
           }
          ],
          "metadata": {
           "kernelspec": {
            "display_name": "Python 3",
            "language": "python",
            "name": "python3"
           },
           "language_info": {
            "codemirror_mode": {
              "name": "ipython"
            },
            "file_extension": ".py",
            "mimetype": "text/x-python",
            "name": "python",
            "nbconvert_exporter": "python",
            "pygments_lexer": "ipython3"
           }
          },
          "nbformat": 4,
          "nbformat_minor": 5
        }
      ]]

      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        local path = opts.args .. ".ipynb"
        local file = io.open(path, "w")
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd("edit " .. path)
        else
          print("Error: Could not open new notebook file for writing.")
        end
      end, { nargs = 1, complete = "file" })
    end,
  },

  -- which-key group labels so pressing \ shows a labeled notebook menu
  -- (the individual entries come from the keymap `desc`s above/below)
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<localleader>", group = "notebook", mode = { "n", "v" }, icon = "󰠮" },
        { "<localleader>r", group = "run", mode = { "n", "v" } },
        { "<localleader>o", group = "output" },
        { "<localleader>m", group = "molten" },
      },
    },
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- registers the BufRead autocmds that convert .ipynb on open
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = { "jmbuhr/otter.nvim" },
    config = function()
      require("quarto").setup({
        lspFeatures = {
          languages = { "python" },
          chunks = "all",
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      })

      local runner = require("quarto.runner")
      local map = vim.keymap.set
      map("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
      map("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
      map("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
      map("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
      map("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
      map("n", "<localleader>RA", function()
        runner.run_all(true)
      end, { desc = "run all cells of all languages", silent = true })
    end,
  },
}
