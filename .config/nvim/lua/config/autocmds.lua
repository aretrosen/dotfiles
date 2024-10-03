local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup

-- check if file has changed externally, and reflect changes
create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = create_augroup("_checktime", { clear = true }),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- highlight text a little longer
create_autocmd("TextYankPost", {
	group = create_augroup("_highlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 750 })
	end,
})

-- if window resized, resize splits to equal size
create_autocmd({ "VimResized" }, {
	group = create_augroup("_resize_splits", { clear = true }),
	callback = function()
		local current_tab = vim.api.nvim_get_current_tabpage()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last location before closing when opening a buffer
create_autocmd("BufReadPost", {
	group = create_augroup("_last_loc", { clear = true }),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf]._last_loc then
			return
		end
		vim.b[buf]._last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with just q, like emacs
create_autocmd("FileType", {
	group = create_augroup("_close_with_q", { clear = true }),
	pattern = {
		"PlenaryTestPopup",
		"grug-far",
		"help",
		"lspinfo",
		"notify",
		"qf",
		"checkhealth",
		"gitsigns.blame",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
			desc = "Quit buffer",
		})
	end,
})

-- auto create directories for a file, like mkdir -p
create_autocmd({ "BufWritePre" }, {
	group = create_augroup("_auto_create_dir", { clear = true }),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})
