vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", {desc="Clear search highlighting"})
vim.keymap.set("n","gl",function()
  vim.diagnostic.open_float({
    scope="buffer",
    header="File diagnostics",
    source="if_many",
    prefix=function(diagnostic)
      return ("%d:%d: "):format(diagnostic.lnum+1,diagnostic.col+1),"Comment"
    end,
  })
end,{desc="Show file diagnostics"})
