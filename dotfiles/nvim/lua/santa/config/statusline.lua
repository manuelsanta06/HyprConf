local colors={
  base="#1e1e2e",
  text="#cdd6f4",
  muted="#6c7086",
  purple="#8f00ff",
  orange="#ff5f00",
  green="#a6e3a1",
  mauve="#cba6f7",
  red="#f38ba8",
  peach="#fab387",
  blue="#89b4fa",
}

return {
  options={
    theme={
      normal={
        a={bg=colors.purple,fg="#ffffff",gui="bold"},
        b={bg=colors.orange,fg="#000000"},
        c={bg=colors.base,fg=colors.text},
      },
      insert={a={bg=colors.green,fg=colors.base,gui="bold"}},
      visual={a={bg=colors.mauve,fg=colors.base,gui="bold"}},
      replace={a={bg=colors.red,fg=colors.base,gui="bold"}},
      command={a={bg=colors.peach,fg=colors.base,gui="bold"}},
      terminal={a={bg=colors.blue,fg=colors.base,gui="bold"}},
      inactive={
        a={bg=colors.base,fg=colors.muted},
        b={bg=colors.base,fg=colors.muted},
        c={bg=colors.base,fg=colors.muted},
      },
    },
    component_separators={left="",right=""},
    section_separators={left="",right=""},
    globalstatus=false,
  },
  sections={
    lualine_a={{"mode",separator={right=""}}},
    lualine_b={
      "branch",
      {
        "diff",
        colored=false,
        -- Reuse Gitsigns data instead of running a second Git diff.
        source=function()
          local status=vim.b.gitsigns_status_dict
          if status then
            return {added=status.added,modified=status.changed,removed=status.removed}
          end
        end,
        symbols={added="+",modified="~",removed="-"},
      },
    },
    lualine_c={{"filename",path=1,symbols={modified="●",readonly="",unnamed="[No Name]"}}},
    lualine_x={
      {"diagnostics",sources={"nvim_diagnostic"},sections={"error","warn"},symbols={error="E:",warn="W:"}},
      "filetype",
    },
    lualine_y={},
    lualine_z={"location"},
  },
  inactive_sections={
    lualine_a={},
    lualine_b={},
    lualine_c={{"filename",path=1}},
    lualine_x={"location"},
    lualine_y={},
    lualine_z={},
  },
  extensions={"neo-tree"},
}
