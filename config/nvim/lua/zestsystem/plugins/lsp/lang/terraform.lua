return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, {
					"terraform",
					"hcl",
				})
			end
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				terraformls = {},
			},
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = function(_, opts)
			if type(opts.sources) == "table" then
				local nls = require("null-ls")

				vim.list_extend(opts.sources, {
					nls.builtins.formatting.terraform_fmt,
					nls.builtins.diagnostics.terraform_validate,
				})
				print("checking null-ls sources from terraform...", opts.sources)
			end
		end,
	},
}
