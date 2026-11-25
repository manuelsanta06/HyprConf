if vim.fn.has("nvim-0.12") == 0 then
  error("This configuration requires Neovim 0.12 or later.")
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("santa.config.options")
require("santa.config.autocmds")
require("santa.config.keymaps")
require("santa.config.diagnostics")
require("santa.lazy")
