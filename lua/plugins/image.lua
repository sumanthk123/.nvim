-- Enable snacks.nvim's image module so opening an image buffer renders it inline.
-- Works in Ghostty via the Kitty graphics protocol (no extra deps needed).
return {
  "folke/snacks.nvim",
  init = function()
    -- Size images by their real pixel dimensions, not DPI metadata.
    -- snacks' fit() divides pixels by DPI to get a "physical" size, which
    -- shrinks high-DPI exports (330dpi logos render at 1/3 size) and inflates
    -- matplotlib PNGs (magick reports per-centimeter values snacks reads as
    -- per-inch). Dropping the info makes fit() read the PNG header instead.
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        local util = require("snacks.image.util")
        local orig_fit = util.fit
        util.fit = function(file, cells, opts)
          opts = opts or {}
          return orig_fit(file, cells, { info = nil, full = opts.full })
        end
      end,
    })
    -- Videos: skip snacks' inline frame preview (slow convert/identify on big
    -- files) and hand them straight to the macOS default video app instead.
    vim.api.nvim_create_autocmd("BufReadCmd", {
      group = vim.api.nvim_create_augroup("open_video_external", { clear = true }),
      pattern = { "*.mp4", "*.mov", "*.avi", "*.mkv", "*.webm" },
      callback = function(ev)
        vim.system({ "open", ev.match })
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            vim.api.nvim_buf_delete(ev.buf, { force = true })
          end
        end)
      end,
    })
    -- Workaround for folke/snacks.nvim#2634 (closed wontfix): a placement
    -- created while the buffer was in a smaller/hidden window is reused as-is
    -- when the buffer is shown again, so the image comes back undersized.
    -- Re-attaching drops the old placement and re-fits to the current window.
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("snacks_image_refit", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].filetype == "image" and package.loaded.snacks then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              Snacks.image.buf.attach(ev.buf)
            end
          end)
        end
      end,
    })
  end,
  opts = {
    image = {
      enabled = true,
      -- Default list minus videos (mp4/mov/avi/mkv/webm) — those open in the
      -- default video app via the BufReadCmd autocmd in init above.
      formats = {
        "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif",
        "pdf", "icns",
      },
      -- Default doc caps are 80x40 cells, which shrinks images in large
      -- windows. Raise them so images fill the available window space
      -- (snacks still clamps to the window and keeps aspect ratio, and
      -- never upscales past an image's native size).
      doc = {
        max_width = 400,
        max_height = 200,
      },
      convert = {
        magick = {
          -- Homebrew's ffmpeg 9 has no webp encoder, which breaks ImageMagick's
          -- default webp intermediate when extracting video frames ("Unknown
          -- encoder 'webp'"). Use pam instead; harmless for regular images.
          default = { "-define", "video:intermediate-format=pam", "{src}[0]", "-scale", "1920x1080>" },
        },
      },
    },
  },
}
