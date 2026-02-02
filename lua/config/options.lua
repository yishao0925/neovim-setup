-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.mouse = ""
vim.opt.clipboard = ""
vim.opt.relativenumber = false

-- Performance
vim.opt.synmaxcol = 240 -- 限制語法高亮的最大列數
vim.opt.updatetime = 200 -- 更快的 CursorHold 觸發
vim.opt.redrawtime = 1500 -- 語法高亮超時限制

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m]"]])
vim.cmd([[let &t_Ce = "\e[4:0m]"]])
