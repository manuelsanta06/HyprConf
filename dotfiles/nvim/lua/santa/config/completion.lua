local cmp = require("cmp")

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    -- Enter only confirms an explicitly selected suggestion.
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
  }, {
    { name = "buffer", keyword_length = 3 },
  }),
})

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-- Tab keeps its indentation behavior when no snippet is active.
for key, direction in pairs({ ["<Tab>"] = 1, ["<S-Tab>"] = -1 }) do
  vim.keymap.set({ "i", "s" }, key, function()
    if vim.snippet.active({ direction = direction }) then
      return "<Cmd>lua vim.snippet.jump(" .. direction .. ")<CR>"
    end
    return key
  end, { expr = true, desc = "Jump between snippet fields" })
end
