return {
  "nvim-flutter/flutter-tools.nvim",
  ft="dart",
  dependencies={
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
  },
  opts=function()
    return {
      -- Flutter Tools owns Dart's LSP client; do not also enable dartls.
      lsp={capabilities=require("cmp_nvim_lsp").default_capabilities()},
    }
  end,
}
