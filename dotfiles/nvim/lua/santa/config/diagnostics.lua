vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  signs = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
