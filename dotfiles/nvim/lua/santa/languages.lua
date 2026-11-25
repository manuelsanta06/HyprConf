-- Add a parser for syntax highlighting; add a server for LSP features.
-- Install server executables separately and make sure they are in PATH
return {
  parsers={
    "c",
    "cpp",
    "dart",
    "go",
    "gomod",
    "gowork",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
  },
  -- Dart's server is managed separately by plugins/flutter.lua.
  servers={
    clangd={},
    gopls={},
  },
}
