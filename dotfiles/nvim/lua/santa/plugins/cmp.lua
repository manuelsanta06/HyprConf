return {
    -- Autocompletado
    { 'hrsh7th/nvim-cmp', dependencies = {
        'hrsh7th/cmp-nvim-lsp',  -- Soporte para LSP
        'hrsh7th/cmp-buffer',    -- Autocompletado desde el buffer
        'hrsh7th/cmp-path',      -- Autocompletado de rutas de archivo
        'hrsh7th/cmp-cmdline',   -- Autocompletado en la línea de comandos
    }},
    
    -- Soporte para LSP
    { 'neovim/nvim-lspconfig' },
}
