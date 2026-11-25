local group = vim.api.nvim_create_augroup("SantaFiletypes", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "make", "automake" },
  desc = "Use literal tabs only in Makefiles",
  callback = function(event)
    vim.bo[event.buf].expandtab = false
    vim.bo[event.buf].tabstop = 8
    vim.bo[event.buf].shiftwidth = 8
    vim.bo[event.buf].softtabstop = 8
  end,
})
