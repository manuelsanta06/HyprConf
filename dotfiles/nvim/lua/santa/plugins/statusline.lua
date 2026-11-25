return {
  "nvim-lualine/lualine.nvim",
  event="VeryLazy",
  dependencies={
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  opts=function()
    return require("santa.config.statusline")
  end,
}
