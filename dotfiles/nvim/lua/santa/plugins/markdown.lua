return {
  "MeanderingProgrammer/render-markdown.nvim",
  event="VeryLazy",
  dependencies={"nvim-treesitter/nvim-treesitter","nvim-tree/nvim-web-devicons"},
  keys={
    {"<leader>mr","<cmd>RenderMarkdown buf_toggle<CR>",desc="Toggle Markdown rendering"},
  },
  opts={sign={enabled=false}},
}
