return {
	{
		"windwp/nvim-ts-autotag",
		event = "VeryLazy",
		opts = {},
	},
	{
		"andymass/vim-matchup",
		event = "BufReadPost",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter-textobjects", "vim-matchup" },
		event = { "VeryLazy" },
		lazy = vim.fn.argc(-1) == 0,
		init = function(plugin)
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		keys = {
			{ "gnn", desc = "Increment Selection" },
			{ "<bs>", desc = "Decrement Selection", mode = "x" },
		},
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			ensure_installed = {
				"asm",
				"bash",
				"bibtex",
				"c",
				"cmake",
				"commonlisp",
				"cpp",
				"css",
				"csv",
				"cuda",
				"diff",
				"disassembly",
				"dockerfile",
				"eex",
				"elixir",
				"erlang",
				"fortran",
				"git_rebase",
				"gitcommit",
				"glsl",
				"go",
				"gomod",
				"gotmpl",
				"gowork",
				"heex",
				"html",
				"java",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"kotlin",
				"latex",
				"lua",
				"luadoc",
				"luap",
				"make",
				"markdown",
				"markdown_inline",
				"menhir",
				"meson",
				"mlir",
				"nasm",
				"ninja",
				"objdump",
				"ocaml",
				"ocaml_interface",
				"ocamllex",
				"perl",
				"powershell",
				"printf",
				"python",
				"query",
				"regex",
				"rust",
				"scss",
				"svelte",
				"systemverilog",
				"toml",
				"tsx",
				"typescript",
				"verilog",
				"vhdl",
				"vimdoc",
				"wgsl",
				"xml",
				"yaml",
				"zig",
			},
			highlight = { enable = true, additional_vim_regex_highlighting = false },
			indent = { enable = true },
			matchup = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn",
					node_incremental = "gnn",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]C"] = "@class.outer",
						["]A"] = "@parameter.inner",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
						["[A"] = "@parameter.inner",
					},
				},
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["ab"] = "@block.outer",
						["ib"] = "@block.inner",
					},
				},
			},
		},
		---@param opts TSConfig
		config = function(_, opts)
			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		keys = {
			{
				"<A-c>",
				function()
					require("treesitter-context").go_to_context()
				end,
				desc = "Jump to upper context",
			},
		},
		opts = {
			mode = "cursor",
			max_lines = 3,
			multiline_threshold = 1,
			min_window_height = 25,
		},
	},
}
