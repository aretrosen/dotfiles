local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local obj = vim.system(
		{ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath },
		{ text = true }
	):wait()
	if obj.code ~= 0 then
		vim.api.nvim_err_write(obj.stderr)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "sen/plugins" },
	},
	defaults = {
		lazy = true,
	},
	install = {
		colorscheme = { "default" },
	},
	custom_keys = {
		["<localleader>l"] = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	change_detection = {
		notify = false,
	},
})
