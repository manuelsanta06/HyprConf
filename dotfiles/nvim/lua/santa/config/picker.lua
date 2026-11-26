local pick=require("mini.pick")

pick.setup({window={config={border="rounded"}}})

local function wrap_text(text,width)
  local lines={}
  for _,paragraph in ipairs(vim.split(text,"\n",{plain=true})) do
    local line=""
    for _,char in ipairs(vim.fn.split(paragraph,"\\zs")) do
      if line~="" and vim.fn.strdisplaywidth(line..char)>width then
        lines[#lines+1]=line
        line=char
      else
        line=line..char
      end
    end
    lines[#lines+1]=line
  end
  return lines
end

vim.ui.select=function(items,opts,on_choice)
  opts=opts or {}
  local format_item=opts.format_item or tostring
  local labels=vim.tbl_map(format_item,items)

  -- Keep custom previews provided by callers; otherwise show the complete label.
  if opts.preview_item==nil then
    opts=vim.tbl_extend("force",opts,{
      preview_item=function(item)
        local width=math.max(1,vim.api.nvim_win_get_width(0)-2)
        return wrap_text(format_item(item),width)
      end,
    })
  end

  local function window_config()
    local width=math.max(40,vim.fn.strdisplaywidth(opts.prompt or "Select")+4)
    for _,label in ipairs(labels) do
      width=math.max(width,vim.fn.strdisplaywidth(label)+4)
    end
    width=math.max(1,math.min(width,vim.o.columns-4))
    local height=#items
    for _,label in ipairs(labels) do
      height=math.max(height,#wrap_text(label,math.max(1,width-2)))
    end
    height=math.max(1,math.min(height,12,vim.o.lines-6))

    return {
      relative="editor",
      anchor="NW",
      border="rounded",
      width=width,
      height=height,
      row=math.max(0,math.floor((vim.o.lines-height-2)/2)),
      col=math.max(0,math.floor((vim.o.columns-width-2)/2)),
    }
  end

  return pick.ui_select(items,opts,on_choice,{window={config=window_config}})
end
