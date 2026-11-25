return {
  "catgoose/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    options = {
      parsers = {
        hex = { rrggbbaa = true },
        names = { enable = true },
        rgb = { enable = true },
      },
    },
  },
}
