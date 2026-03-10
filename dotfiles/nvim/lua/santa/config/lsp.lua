local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function setup_server(server_name, config)
  config = config or {}
  config.capabilities = capabilities
  for k, v in pairs(config) do
    vim.lsp.config[server_name][k] = v
  end
  
  vim.lsp.enable(server_name)
end


-- C / C++
setup_server("clangd", {
  cmd = { "clangd", "--compile-commands-dir=build" }
})

-- Go
setup_server("gopls", {})

-- Python
setup_server("pyright", {})

-- TypeScript
setup_server("ts_ls", {})

-- CSS
setup_server("cssls", {})


vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = true,
  virtual_lines = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  signs = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Colores personalizados
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {fg = "#ff0000" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn" , {fg = "#f28907" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo" , {fg = "#ffffff" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint" , {fg = "#ffffff" , bg = "NONE"})
