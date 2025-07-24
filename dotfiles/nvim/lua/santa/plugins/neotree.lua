return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- Optional image support for file preview: See `# Preview Mode` for more information.
    {"3rd/image.nvim", opts = {}},
  },
  lazy = false, -- neo-tree lazily loads itself
  ---@module "neo-tree"
  ---@type neotree.Config?
  opts = {
    window = {
        width = 25, -- ancho del panel
    },
    close_if_last_window = false,
    sort_case_insensitive = true,
    enable_git_status = true,

    default_component_configs = {
        container = {
            enable_character_fade = true,
        },
        indent = {
            indent_size = 2,
            padding = 1, -- extra padding on left hand side
            -- indent guides
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expander
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
        },
        icon = {
        },
        name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
        },
    },
  },
}
