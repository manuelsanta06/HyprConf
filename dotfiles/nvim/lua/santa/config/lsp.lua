local lspconfig = require'lspconfig'

lspconfig.clangd.setup({      --para C y C++
    cmd = { "clangd", "--compile-commands-dir=build" }
})
lspconfig.pyright.setup({}) --para piton
lspconfig.ts_ls.setup({})   --para javascript y typescript

--para css (no anda)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.cssls.setup({
    capabilities = capabilities,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {fg = "#ff0000" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn" , {fg = "#f28907" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo" , {fg = "#ffffff" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint" , {fg = "#ffffff" , bg = "NONE"})

vim.o.signcolumn = "no"
