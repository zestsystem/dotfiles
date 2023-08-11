return {
	-- add svelte to treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "svelte" })
			end
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				svelte = {},
			},
		},
	},
}
