local opt=vim.opt

opt.termguicolors=true
opt.winborder="rounded"
opt.winblend=0
opt.number=true
opt.relativenumber=true
opt.mouse="a"
opt.hlsearch=true

opt.expandtab=true
opt.tabstop=2
opt.shiftwidth=2
opt.softtabstop=2

opt.foldmethod="indent"
opt.foldlevel=99
opt.foldlevelstart=99
opt.laststatus=2
opt.title=true
opt.titlestring="%t"
opt.clipboard:append("unnamedplus")

-- Keep traditional syntax highlighting as a fallback when no parser is available.
vim.cmd.syntax("enable")
