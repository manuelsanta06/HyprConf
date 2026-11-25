return {
  "lewis6991/gitsigns.nvim",
  event={"BufReadPre","BufNewFile"},
  keys={
    {"<leader>gp","<cmd>Gitsigns preview_hunk<CR>",desc="Preview Git change"},
  },
  opts={
    signcolumn=true,
    numhl=true,
    linehl=false,
    current_line_blame=false,
    attach_to_untracked=true,
    preview_config={border="rounded"},
  },
}
