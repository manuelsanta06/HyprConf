return {
  "folke/lazydev.nvim",
  ft="lua",
  opts={
    -- Keep native project roots so each Lua environment stays separate.
    integrations={lspconfig=false},
    library={
      {path="${3rd}/luv/library",words={"vim%.uv"}},
    },
    enabled=function(root_dir)
      local root=vim.uv.fs_realpath(root_dir)
      local config=vim.uv.fs_realpath(vim.fn.stdpath("config"))
      return root~=nil and root==config
    end,
  },
}
