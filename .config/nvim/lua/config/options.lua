local M = { skip_foldexpr = {} }
local skip_check = assert(vim.uv.new_check())
function M.foldexpr()
	local buf = vim.api.nvim_get_current_buf()

	if M.skip_foldexpr[buf] or vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "" then
		return "0"
	end

	local ok = pcall(vim.treesitter.get_parser, buf)

	if ok then
		return vim.treesitter.foldexpr()
	end

	M.skip_foldexpr[buf] = true
	skip_check:start(function()
		M.skip_foldexpr = {}
		skip_check:stop()
	end)
	return "0"
end

local o = vim.opt

-- write all changes when exiting any way
o.autowriteall = true

-- show line numbers, signcolumn, and tabline
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.showtabline = 2

-- split below and right
o.splitbelow = true
o.splitright = true

-- use global clipboard
o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

-- completion option for better nvim-cmp
o.completeopt = "menu,menuone,noinsert,noselect"
o.wildmode = "longest:full,full"

-- show some special characters
o.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}
o.list = true
o.listchars = {
	tab = "» ",
	eol = "↲",
	nbsp = "␣",
	lead = "·",
	trail = "␣",
	extends = "↴",
	precedes = "→",
}
o.showbreak = "↪ "

-- don't need mouse everytime, don't need ruler
o.mouse = "n"
o.ruler = false

-- show end column
o.colorcolumn = "+1"
o.textwidth = 80

-- popup-menu options
o.pumblend = 15
o.pumheight = 15

-- text scroll options
o.scrolloff = 20
o.sidescrolloff = 10
o.smoothscroll = true

-- time for update, and various timeouts
o.timeoutlen = 350
o.ttimeoutlen = 20
o.updatetime = 150

-- grep options
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"

-- spelling options
o.spelllang = { "en_us" }
o.spelloptions = "camel"

-- saner settings for tabs and spaces
-- NOTE: I like indent to be tabs, if otherwise enforced (like python)
-- o.expandtab = true
o.shiftround = true
o.shiftwidth = 4
o.smartindent = true
o.softtabstop = 4
o.tabstop = 4

-- smarter case detection
o.smartcase = true
o.infercase = true

-- conceal text
o.conceallevel = 1

-- store state of vim
o.undofile = true
o.shada = [[!,'50,<50,s100,h]]
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- ease of text selection in virtual mode
o.virtualedit = "block"

-- options to control nvim folds
o.foldtext = ""
o.foldmethod = "expr"
o.foldlevelstart = 1
o.foldnestmax = 5
o.foldexpr = "v:lua.require'config.options'.foldexpr()"

return M
