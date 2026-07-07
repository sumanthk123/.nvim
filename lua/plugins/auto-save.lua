-- Auto-save buffers on leaving insert mode / text change.
return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    -- only save real, modifiable, named files (skips scratch/special buffers)
    condition = function(buf)
      local ok = vim.api.nvim_get_option_value
      if vim.fn.getbufvar(buf, "&modifiable") == 1 and ok("buftype", { buf = buf }) == "" then
        return true
      end
      return false
    end,
    debounce_delay = 1000, -- wait 1s after the last change before writing
  },
}
