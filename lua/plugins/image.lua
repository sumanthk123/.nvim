-- Enable snacks.nvim's image module so opening an image buffer renders it inline.
-- Works in Ghostty via the Kitty graphics protocol (no extra deps needed).
return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = true },
  },
}
