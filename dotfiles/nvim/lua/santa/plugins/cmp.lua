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

      -- AQUÍ ESTÁ LA MAGIA:
      -- 1. nvim-cmp depende de nvim-lspconfig
      {
        'neovim/nvim-lspconfig',
        
        -- 2. nvim-lspconfig depende de cmp-nvim-lsp
        --    (Esto fuerza a cmp-nvim-lsp a cargarse PRIMERO)
        dependencies = {
          'hrsh7th/cmp-nvim-lsp'
        },
        
        -- 3. La config de lspconfig (lsp.lua) ahora se ejecuta
        --    DESPUÉS de que cmp-nvim-lsp esté cargado y listo.
        config = function()
          require("santa.config.lsp")
        end
      }
    },
    
    config = function()
      -- 4. La config de cmp se ejecuta al FINAL de todo,
      --    cuando lsp.lua ya terminó y todo está listo.
      require("santa.config.cmp-config") 
    end
  },

  -- Treesitter (coloreado + parser inteligente)
  { 
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Asegúrate de tener estos dos parsers
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown", -- <-- Este
          "markdown_inline", -- <-- Y este
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
