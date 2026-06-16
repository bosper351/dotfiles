-- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua

vim.o.number = true
vim.o.mouse = 'a'
vim.o.mousescroll='ver:2,hor:1'
vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true

