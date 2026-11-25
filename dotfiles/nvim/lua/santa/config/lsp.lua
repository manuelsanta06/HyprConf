local group = vim.api.nvim_create_augroup("SantaLsp",{clear=true})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    local function map(key, action, desc)
      vim.keymap.set("n", key, action, { buffer = event.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "Show references")
    map("K", vim.lsp.buf.hover, "Show documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
    map("<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")
  end,
})

vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

for name, settings in pairs(require("santa.languages").servers) do
  vim.lsp.config(name, settings)
  local cmd = vim.lsp.config[name].cmd
  if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then
    vim.lsp.enable(name)
  else
    vim.schedule(function()
      vim.notify("LSP " .. name .. ": executable not found: " .. cmd[1], vim.log.levels.WARN)
    end)
  end
end
