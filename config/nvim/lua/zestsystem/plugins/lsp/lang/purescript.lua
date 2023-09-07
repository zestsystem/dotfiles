return {
	-- Syntax highlighting
	{ "purescript-contrib/purescript-vim" },

	-- LspConfig
	{
		"neovim/nvim-lspconfig",

		---@class PluginLspOpts
		opts = {
			servers = {
				purescriptls = {
					settings = {
						purescript = {
							addSpagoSources = true,
							addNpmPath = true,
							formatter = "purs-tidy",
						},
					},
					root_dir = function(path)
						local util = require("lspconfig.util")
						if path:match("/.spago/") then
							return nil
						end
						return util.root_pattern(
							"bower.json",
							"psc-package.json",
							"spago.dhall",
							"flake.nix",
							"shell.nix"
						)(path)
					end,
				},
			},
		},
	},

	{
		"L3MON4D3/LuaSnip",
		opts = function()
			local ls = require("luasnip")
			local s = ls.snippet
			local t = ls.text_node

			ls.add_snippets("purescript", {
				s("fa", {
					t("∀"),
				}),
			})
		end,
	},
}
