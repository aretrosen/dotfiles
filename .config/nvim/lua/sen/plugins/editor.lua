return {
	{
		"willothy/flatten.nvim",
		opts = {},
		lazy = false,
		priority = 1002,
	},
	{
		"MagicDuck/grug-far.nvim",
		opts = { headerMaxWidth = 81 },
		cmd = "GrugFar",
		keys = {
			{
				"<leader>xg",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		config = true,
		keys = function()
			local flash = require("flash")
			return {
				{
					"s",
					mode = { "n", "x", "o" },
					function()
						flash.jump()
					end,
					desc = "Flash Search",
				},
				{
					"S",
					mode = { "n", "o", "x" },
					function()
						flash.treesitter()
					end,
					desc = "Flash Treesitter",
				},
			}
		end,
	},
	{
		"numToStr/Comment.nvim",
		keys = {
			{
				"gc",
				mode = { "n", "v" },
				desc = "Comment",
			},
			{
				"gb",
				mode = { "n", "v" },
				desc = "Block Comment",
			},
		},
		opts = {},
	},
	{ "tpope/vim-characterize", keys = { { "gC", "<Plug>(characterize)" } } },
	{ "echasnovski/mini.align", keys = { { "ga", mode = { "n", "v" } }, { "gA", mode = { "n", "v" } } }, opts = {} },
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = "plenary.nvim",
		opts = {
			menu = {
				width = vim.api.nvim_win_get_width(0) - 4,
			},
			settings = {
				save_on_toggle = true,
			},
		},
		keys = {
			{
				"<leader>hm",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon File",
			},
			{
				"<leader>hl",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon Quick Menu",
			},
		},
	},
	{
		"danymat/neogen",
		cmd = "Neogen",
		keys = {
			{
				"<leader>ga",
				function()
					require("neogen").generate()
				end,
				desc = "Generate Annotations (Neogen)",
			},
		},
		opts = {
			snippet_engine = "luasnip",
		},
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		opts = {},
	},
	{
		"monaqa/dial.nvim",
		keys = function()
			local dial = function(increment, g, mode)
				local is_visual = mode == "v" or mode == "V" or mode == ""
				local func = (increment and "inc" or "dec")
					.. (g and "_g" or "_")
					.. (is_visual and "visual" or "normal")
				local group = ({
					css = "css",
					javascript = "typescript",
					javascriptreact = "typescript",
					json = "json",
					lua = "lua",
					markdown = "markdown",
					python = "python",
					sass = "css",
					scss = "css",
					typescript = "typescript",
					typescriptreact = "typescript",
					yaml = "yaml",
				})[vim.bo.filetype] or "default"
				return require("dial.map")[func](group)
			end

			-- stylua: ignore
			return {
				{ "<C-a>", function() return dial(true, false, vim.api.nvim_get_mode().mode) end, expr = true, desc = "Increment", mode = { "n", "v" }, },
				{ "<C-x>", function() return dial(false, false, vim.api.nvim_get_mode().mode) end, expr = true, desc = "Decrement", mode = { "n", "v" }, },
				{ "g<C-a>", function() return dial(true, true, vim.api.nvim_get_mode().mode) end, expr = true, desc = "Increment", mode = { "n", "v" }, },
				{ "g<C-x>", function() return dial(false, true, vim.api.nvim_get_mode().mode) end, expr = true, desc = "Decrement", mode = { "n", "v" }, },
			}
		end,
		opts = function()
			local augend = require("dial.augend")

			local logical_alias = augend.constant.new({
				elements = { "&&", "||" },
				word = false,
				cyclic = true,
			})

			local ordinal_numbers = augend.constant.new({
				-- elements through which we cycle. When we increment, we go down
				-- On decrement we go up
				elements = {
					"first",
					"second",
					"third",
					"fourth",
					"fifth",
					"sixth",
					"seventh",
					"eighth",
					"ninth",
					"tenth",
				},
				-- if true, it only matches strings with word boundary. firstDate wouldn't work for example
				word = false,
				-- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
				-- Otherwise nothing will happen when there are no further values
				cyclic = true,
			})

			local weekdays = augend.constant.new({
				elements = {
					"Monday",
					"Tuesday",
					"Wednesday",
					"Thursday",
					"Friday",
					"Saturday",
					"Sunday",
				},
				word = true,
				cyclic = true,
			})

			local months = augend.constant.new({
				elements = {
					"January",
					"February",
					"March",
					"April",
					"May",
					"June",
					"July",
					"August",
					"September",
					"October",
					"November",
					"December",
				},
				word = true,
				cyclic = true,
			})

			local capitalized_boolean = augend.constant.new({
				elements = {
					"True",
					"False",
				},
				word = true,
				cyclic = true,
			})

			return {
				groups = {
					default = {
						augend.integer.alias.decimal, -- nonnegative decimal number (0, 1, 2, 3, ...)
						augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
						augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
						ordinal_numbers,
						weekdays,
						months,
					},
					typescript = {
						augend.integer.alias.decimal, -- nonnegative and negative decimal number
						augend.constant.alias.bool, -- boolean value (true <-> false)
						logical_alias,
						augend.constant.new({ elements = { "let", "const" } }),
					},
					yaml = {
						augend.integer.alias.decimal, -- nonnegative and negative decimal number
						augend.constant.alias.bool, -- boolean value (true <-> false)
					},
					css = {
						augend.integer.alias.decimal, -- nonnegative and negative decimal number
						augend.hexcolor.new({
							case = "lower",
						}),
						augend.hexcolor.new({
							case = "upper",
						}),
					},
					markdown = {
						augend.misc.alias.markdown_header,
					},
					json = {
						augend.integer.alias.decimal, -- nonnegative and negative decimal number
						augend.semver.alias.semver, -- versioning (v1.1.2)
					},
					lua = {
						augend.integer.alias.decimal, -- nonnegative and negative decimal number
						augend.constant.alias.bool, -- boolean value (true <-> false)
						augend.constant.new({
							elements = { "and", "or" },
							word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
							cyclic = true, -- "or" is incremented into "and".
						}),
					},
					python = {
						augend.integer.alias.decimal, -- nonnegative and negative decimal number
						capitalized_boolean,
						logical_alias,
					},
				},
			}
		end,
		config = function(_, opts)
			require("dial.config").augends:register_group(opts.groups)
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		dependencies = "nvim-treesitter",
		event = "VeryLazy",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			},
			current_line_blame_formatter = "	<author>, <author_time:%R> - <summary>",
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
				local next_hunk_repeat, prev_hunk_repeat =
					ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
				end

				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						next_hunk_repeat()
					end
				end, "Next Hunk")
				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						prev_hunk_repeat()
					end
				end, "Prev Hunk")
				map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
				map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
				map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
				map("n", "<leader>ghd", function()
					gs.diffthis("~")
				end, "Diff This ~")

				map("n", "<leader>gbs", gs.stage_buffer, "Stage Buffer")
				map("n", "<leader>gbr", gs.reset_buffer, "Reset Buffer")
				map("n", "<leader>gbb", function()
					gs.blame()
				end, "Blame Buffer")
			end,
		},
	},
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
		},
		keys = function()
			local trouble = require("trouble")
			return {
				{ "<leader>td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
				{ "<leader>tl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
				{ "<leader>ts", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
				{
					"<leader>tb",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{ "<leader>tL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
				{ "<leader>tQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
				{
					"[q",
					function()
						if trouble.is_open() then
							trouble.prev({ skip_groups = true, jump = true })
						else
							local ok, err = pcall(vim.cmd.cprev)
							if not ok then
								vim.notify(err, vim.log.levels.ERROR)
							end
						end
					end,
					desc = "Previous Trouble/Quickfix Item",
				},
				{
					"]q",
					function()
						if trouble.is_open() then
							trouble.next({ skip_groups = true, jump = true })
						else
							local ok, err = pcall(vim.cmd.cnext)
							if not ok then
								vim.notify(err, vim.log.levels.ERROR)
							end
						end
					end,
					desc = "Next Trouble/Quickfix Item",
				},
			}
		end,
	},
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		keys = {
			{ "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files (current directory)" },
			{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" },
			{ "<leader>/", "<cmd>FzfLua live_grep_resume<cr>", desc = "Live Grep (current directory)" },
		},
		opts = {},
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "mini.icons" },
		cmd = "Oil",
		keys = {
			{
				"<F2>",
				function()
					require("oil").toggle_float()
				end,
				desc = "Oil File Explorer (cwd)",
			},
		},
		opts = {
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			float = {
				padding = 1,
				max_width = 40,
				override = function(conf)
					conf["col"] = vim.o.columns - conf.width
					conf["zindex"] = 50
				end,
			},
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					local dontshow = { "node_modules" }
					return vim.tbl_contains(dontshow, name)
				end,
			},
		},
	},
}
