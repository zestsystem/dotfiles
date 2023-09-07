return {

	-- add typescript to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
			end
		end,
	},

	-- correctly setup lspconfig
	{
		"neovim/nvim-lspconfig",
		dependencies = { "jose-elias-alvarez/typescript.nvim" },
		opts = {
			servers = {
				---@type lspconfig.options.tsserver
				tsserver = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,
					keys = {
						{ "<leader>co", "<cmd>TypescriptOrganizeImports<CR>", desc = "Organize Imports" },
						{ "<leader>cR", "<cmd>TypescriptRenameFile<CR>", desc = "Rename File" },
					},
					settings = {
						typescript = {
							format = {
								indentSize = vim.o.shiftwidth,
								convertTabsToSpaces = vim.o.expandtab,
								tabSize = vim.o.tabstop,
							},
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							format = {
								indentSize = vim.o.shiftwidth,
								convertTabsToSpaces = vim.o.expandtab,
								tabSize = vim.o.tabstop,
							},
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						completions = {
							completeFunctionCalls = true,
						},
					},
				},
			},
			setup = {
				tsserver = function(_, opts)
					require("typescript").setup({ server = opts })
					return true
				end,
			},
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = function(_, opts)
			table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
		end,
	},
	{
		"mfussenegger/nvim-dap",
		optional = true,
		opts = function()
			local dap = require("dap")
			if not dap.adapters["pwa-node"] then
				require("dap").adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
					},
				}
			end
			for _, language in ipairs({ "typescript", "javascript" }) do
				if not dap.configurations[language] then
					dap.configurations[language] = {
						{
							type = "pwa-node",
							request = "launch",
							name = "Launch file",
							program = "${file}",
							cwd = "${workspaceFolder}",
						},
						{
							type = "pwa-node",
							request = "attach",
							name = "Attach",
							processId = require("dap.utils").pick_process,
							cwd = "${workspaceFolder}",
						},
					}
				end
			end
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		opts = function()
			local ls = require("luasnip")
			local s = ls.snippet
			local t = ls.text_node
			local i = ls.insert_node

			local effectSnippets = {
				s("gen_", {
					t("function* (_)"),
					t({ "{", "\t" }),
					i(0),
					t({ "", "}" }),
				}),
				s("egen_", {
					t("Effect.gen("),
					t("function* (_)"),
					t({ "{", "\t" }),
					i(0),
					t({ "", "}" }),
					t(")"),
				}),
				s("yield_", {
					t("yield* _"),
					t("("),
					i(0),
					t(")"),
				}),
				s("cyield_", {
					t("const "),
					i(1),
					t(" = "),
					t("yield* _"),
					t("("),
					i(0),
					t(")"),
				}),
				s("epipe", {
					t({ "pipe(", "\t" }),
					i(0),
					t({ "", ")" }),
				}),
			}

			ls.add_snippets("javascript", effectSnippets)
			ls.add_snippets("typescript", effectSnippets)
		end,
	},
}
