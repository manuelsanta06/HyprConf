return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    transparent_background = true,
    custom_highlights = function()
      return {
        Normal = { bg = "NONE" },
        NormalNC = { bg = "NONE" },
        EndOfBuffer = { bg = "NONE" },
        VertSplit = { bg = "NONE" },
        SignColumn = { bg = "NONE" },
        TabLine = { bg = "NONE" },
        TabLineFill = { bg = "NONE" },
        TabLineSel = { bg = "NONE" },
        FloatBorder = { bg = "NONE" },
        NormalFloat = { bg = "NONE" },
        StatusLine = { bg = "#8f00ff", fg = "#ffffff" },
        StatusLineNC = { bg = "#1e1e1e", fg = "#ffffff" },
        LineNr = { fg = "#ffffff" },
        LineNrAbove = { fg = "#ffffff" },
        LineNrBelow = { fg = "#ffffff" },
        DiagnosticVirtualLinesError = { fg = "#ff0000", bg = "NONE" },
        DiagnosticVirtualLinesWarn = { fg = "#f28907", bg = "NONE" },
        DiagnosticVirtualLinesInfo = { fg = "#ffffff", bg = "NONE" },
        DiagnosticVirtualLinesHint = { fg = "#ffffff", bg = "NONE" },
      }
    end,
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}
