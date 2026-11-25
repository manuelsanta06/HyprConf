return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
    { "<C-S-e>", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
  },
  opts = {
    window = { width = 25 },
    close_if_last_window = false,
    sort_case_insensitive = true,
    enable_git_status = true,
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
      },
      name = { use_git_status_colors = true },
    },
  },
}
