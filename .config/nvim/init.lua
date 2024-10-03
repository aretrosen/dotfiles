if vim.env.VSCODE then
	vim.g.vscode = true
end

if vim.loader then
	vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")
