local function custom_attach(client, bufnr)
	local map = vim.keymap.set

	if client.supports_method("textDocument/definition") then
		map("n", "gd", "<cmd>FzfLua lsp_definitions<cr>", { desc = "Goto Definition", buffer = bufnr })
	end
	if client.supports_method("textDocument/declaration") then
		map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration", buffer = bufnr })
	end
	if client.supports_method("textDocument/codeAction") then
		map({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<cr>", { desc = "Code Action", buffer = bufnr })
	end
	if client.supports_method("textDocument/rename") then
		map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename", buffer = bufnr })
	end
	if client.supports_method("textDocument/signatureHelp") then
		map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help", buffer = bufnr })
	end

	map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation", buffer = bufnr })
	map("n", "gr", "<cmd>FzfLua lsp_references<cr>", { desc = "Goto References", buffer = bufnr })
	map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition", buffer = bufnr })
	map("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = bufnr })

	if
		client.supports_method("textDocument/inlayHint")
		and vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].buftype == ""
		and not vim.tbl_contains({}, vim.bo[bufnr].filetype)
	then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	if client.supports_method("textDocument/codeLens") then
		vim.lsp.codelens.refresh()
		vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
			buffer = bufnr,
			callback = vim.lsp.codelens.refresh,
		})
		map({ "n", "v" }, "<leader>cl", vim.lsp.codelens.run, { desc = "Run Codelens", buffer = bufnr })
	end
end

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = "b0o/SchemaStore.nvim",
		keys = {
			{ "[d", vim.diagnostic.goto_prev, desc = "Previous Diagnostics" },
			{ "]d", vim.diagnostic.goto_next, desc = "Next Diagnostics" },
		},
		opts = {
			diagnostics = {
				signs = {
					Error = " ",
					Warn = " ",
					Hint = " ",
					Info = " ",
				},
			},
			capabilities = {
				workspace = {
					fileOperations = {
						didRename = true,
						willRename = true,
					},
				},
			},
			servers = {
				bashls = {},
				taplo = {},
				svelte = {},
				tailwindcss = {},
				neocmake = {},
				dockerls = {},
				docker_compose_language_service = {},
				clangd = {
					attach = function(client, bufnr)
						custom_attach(client, bufnr)
					end,
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(
							"Makefile",
							"configure.ac",
							"configure.in",
							"config.h.in",
							"meson.build",
							"meson_options.txt",
							"build.ninja"
						)(fname) or require("lspconfig.util").root_pattern(
							"compile_commands.json",
							"compile_flags.txt"
						)(fname) or require("lspconfig.util").find_git_ancestor(fname)
					end,
					capabilities = {
						offsetEncoding = { "utf-16" },
					},
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
				},
				elixirls = {},
				gopls = {
					attach = function(client, bufnr)
						if not client.server_capabilities.semanticTokensProvider then
							local semantic = client.config.capabilities.textDocument.semanticTokens
							client.server_capabilities.semanticTokensProvider = {
								full = true,
								legend = {
									tokenTypes = semantic.tokenTypes,
									tokenModifiers = semantic.tokenModifiers,
								},
								range = true,
							}
						end
						custom_attach(client, bufnr)
					end,
					settings = {
						gopls = {
							gofumpt = true,
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								fieldalignment = true,
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
							semanticTokens = true,
						},
					},
				},
				ocamllsp = {
					filetypes = {
						"ocaml",
						"ocaml.menhir",
						"ocaml.interface",
						"ocaml.ocamllex",
						"reason",
						"dune",
					},
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(
							"*.opam",
							"esy.json",
							"package.json",
							".git",
							"dune-project",
							"dune-workspace",
							"*.ml"
						)(fname)
					end,
				},
				eslint = {
					settings = {
						workingDirectories = { mode = "auto" },
					},
				},
				jsonls = {
					settings = {
						json = {
							validate = { enable = true },
							format = { enable = true },
						},
					},
					on_new_config = function(new_config)
						new_config.settings.json.schemas = new_config.settings.json.schemas or {}
						vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
					end,
				},
				yamlls = {
					capabilities = {
						textDocument = {
							foldingRange = {
								dynamicRegistration = false,
								lineFoldingOnly = true,
							},
						},
					},
					on_new_config = function(new_config)
						new_config.settings.yaml.schemas = vim.tbl_deep_extend(
							"force",
							new_config.settings.yaml.schemas or {},
							require("schemastore").yaml.schemas()
						)
					end,
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							keyOrdering = false,
							format = {
								enable = true,
							},
							validate = true,
							schemaStore = {
								enable = false,
								url = "",
							},
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							codeLens = {
								enable = true,
							},
							completion = {
								callSnippet = "Replace",
							},
							doc = {
								privateName = { "^_" },
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
			},
		},
		config = function(_, opts)
			for name, icon in pairs(opts.diagnostics.signs) do
				name = "DiagnosticSign" .. name
				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				title = "hover",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				title = "signature_help",
			})

			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = function(diagnostic)
						for d, icon in pairs(opts.diagnostics.signs) do
							if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
								return icon
							end
							return " "
						end
					end,
				},
			})

			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_nvim_lsp.default_capabilities(),
				opts.capabilities
			)

			local function server_setup(server_name, server_opts)
				local attach_fn = server_opts.attach or custom_attach

				server_opts["attach"] = nil

				require("lspconfig")[server_name].setup(
					vim.tbl_extend("force", { on_attach = attach_fn, capabilities = capabilities }, server_opts or {})
				)
			end

			for name, server_opts in pairs(opts.servers) do
				server_setup(name, server_opts)
			end
		end,
	},
	{
		"lervag/vimtex",
		ft = { "tex", "plaintex", "bib" },
		config = function()
			vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
			vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
		end,
	},
	{
		"Civitasv/cmake-tools.nvim",
		init = function()
			local loaded = false
			local function check()
				local cwd = vim.uv.cwd()
				if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
					require("lazy").load({ plugins = { "cmake-tools.nvim" } })
					loaded = true
				end
			end
			check()
			vim.api.nvim_create_autocmd("DirChanged", {
				callback = function()
					if not loaded then
						check()
					end
				end,
			})
		end,
		opts = {},
	},
	{
		"mrcjkb/rustaceanvim",
		ft = { "rust" },
		opts = {
			server = {
				on_attach = function(client, bufnr)
					vim.keymap.set("n", "<leader>cR", function()
						vim.cmd.RustLsp("codeAction")
					end, { desc = "Code Action", buffer = bufnr })
					vim.keymap.set("n", "<leader>dr", function()
						vim.cmd.RustLsp("debuggables")
					end, { desc = "Rust Debuggables", buffer = bufnr })
					custom_attach(client, bufnr)
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = {
								enable = true,
							},
						},
						-- Add clippy lints for Rust.
						checkOnSave = true,
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			},
		},
	},
}
