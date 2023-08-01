return {

	-- copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},

	-- copilot cmp source
	{
		"nvim-cmp",
		dependencies = {
			{
				"zbirenbaum/copilot-cmp",
				dependencies = "copilot.lua",
				opts = {},
				config = function(_, opts)
					local copilot_cmp = require("copilot_cmp")
					copilot_cmp.setup(opts)
					-- attach cmp source whenever copilot attaches
					-- fixes lazy-loading issues with the copilot cmp source
					require("zestsystem.util").on_attach(function(client)
						if client.name == "copilot" then
							copilot_cmp._on_insert_enter({})
						end
					end)
				end,
			},
		},
		---@param opts cmp.ConfigSchema
		opts = function(_, opts)
			table.insert(opts.sources, 1, { name = "copilot", group_index = 2 })
			opts.sorting = opts.sorting or require("cmp.config.default")().sorting
			table.insert(opts.sorting.comparators, 1, require("copilot_cmp.comparators").prioritize)
		end,
	},
}
