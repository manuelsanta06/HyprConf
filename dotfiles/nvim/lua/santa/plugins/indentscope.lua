return {
  "nvim-mini/mini.indentscope",
  main="mini.indentscope",
  event="VeryLazy",
  opts=function()
    return {
      symbol="╎",
      options={try_as_border=true},
      mappings={object_scope="",object_scope_with_border="",goto_top="",goto_bottom=""},
      draw={
        delay=100,
        animation=require("mini.indentscope").gen_animation.quadratic({duration=160,unit="total",easing="out"}),
        predicate=function(scope)
          return vim.bo[scope.buf_id].buftype=="" and not scope.body.is_incomplete
        end,
      },
    }
  end,
}
