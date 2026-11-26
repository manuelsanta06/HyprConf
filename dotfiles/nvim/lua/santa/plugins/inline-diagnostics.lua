return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event="LspAttach",
  keys={
    {"<leader>td",function()
      require("tiny-inline-diagnostic").toggle()
    end,desc="Toggle inline diagnostics"},
  },
  opts={
    preset="ghost",
    options={
      add_messages={
        display_count=true,
      },
      severity={vim.diagnostic.severity.ERROR,vim.diagnostic.severity.WARN},
      show_code=false,
      show_source={enabled=false},
      show_related={enabled=true},
      multilines={enabled=true},
      show_all_diags_on_cursorline=true,
      enable_on_insert=false,
      enable_on_select=false,
      override_open_float=true,
    },
  },
}
