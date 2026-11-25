local treesitter = require("nvim-treesitter")
treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

local function highlight(buf)
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
    -- Filetypes without a parser keep traditional syntax highlighting.
    pcall(vim.treesitter.start, buf)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("SantaTreesitter", { clear = true }),
  callback = function(event)
    highlight(event.buf)
  end,
})

local installed = treesitter.get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
  return not vim.list_contains(installed, lang)
end, require("santa.languages").parsers)

if #missing > 0 then
  if vim.fn.executable("tree-sitter") == 0 then
    vim.schedule(function()
      vim.notify("Install tree-sitter-cli to download missing syntax parsers.", vim.log.levels.WARN)
    end)
  else
    treesitter.install(missing):await(function(err, success)
      vim.schedule(function()
        if err or not success then
          vim.notify("Parser installation failed. Check :messages and retry with :TSInstall.", vim.log.levels.WARN)
        end
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          highlight(buf)
        end
      end)
    end)
  end
end
