local lspconfig_util = require('lspconfig.util')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- para C y C++
vim.lsp.config.clangd.cmd = { "clangd", "--compile-commands-dir=build" }
vim.lsp.config.clangd.capabilities = capabilities

-- para Python
vim.lsp.config.pyright.capabilities = capabilities

-- para TypeScript
vim.lsp.config.ts_ls.capabilities = capabilities

-- para CSS
vim.lsp.config.cssls.capabilities = capabilities

-- para Dart (Flutter)
vim.lsp.config.dartls.cmd = { vim.fn.expand("~/clons/flutter/bin/dart"), "language-server", "--protocol=lsp" }
vim.lsp.config.dartls.capabilities = capabilities
vim.lsp.config.dartls.root_dir = lspconfig_util.root_pattern("pubspec.yaml")

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {fg = "#ff0000" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn" , {fg = "#f28907" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo" , {fg = "#ffffff" , bg = "NONE"})
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint" , {fg = "#ffffff" , bg = "NONE"})

vim.o.signcolumn = "no"

--require("flutter-tools").setup{
--  lsp = {
--    capabilities = require("cmp_nvim_lsp").default_capabilities(),
--    on_attach = function(_, bufnr)
--      local opts = { buffer = bufnr, noremap = true, silent = true }
--      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
--      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
--      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
--      vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
--    end,
--  },
--}

