return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Dependencias directas de CMP
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      { 'L3MON4D3/LuaSnip', version = "v2.*", build = "make install_jsregexp" },
      'rafamadriz/friendly-snippets',

      {
        'neovim/nvim-lspconfig',
        event = { "BufReadPre", "BufNewFile" },
        
        dependencies = {
          'hrsh7th/cmp-nvim-lsp'
        },
        
        config = function()
          require("santa.config.lsp")
        end
      }
    },
    
    config = function()
      require("santa.config.cmp-config") 
    end
  },

  { 
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          "go",
          "gomod"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Sintaxis Dart
  { 'dart-lang/dart-vim-plugin' },

  -- Integración Flutter
  {
    'akinsho/flutter-tools.nvim',
    ft="dart",
    dependencies = { 'nvim-lua/plenary.nvim', 'stevearc/dressing.nvim' },
    
    config = function()
      require("flutter-tools").setup{
        lsp = {
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr, noremap = true, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
          end,
        },
      }
    end
  },
}
