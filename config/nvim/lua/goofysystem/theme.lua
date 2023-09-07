local rosepine = require 'rose-pine'
local colorizer = require 'colorizer'
local gitsigns = require 'gitsigns'
local lualine = require 'lualine'
local noice = require 'noice'

local function init()
    rosepine.setup({
        disable_background = true,
    })

    colorizer.setup {}

    gitsigns.setup {}

    lualine.setup {
        options = {
            component_separators = { left = '', right = '' },
            extensions = { "fzf", "quickfix" },
            icons_enabled = false,
            section_separators = { left = '', right = '' },
            theme = "rose-pine"
        },
        sections = {
            lualine_x = {
                {
                    noice.api.status.message.get_hl,
                    cond = noice.api.status.message.has,
                },
                {
                    noice.api.status.command.get,
                    cond = noice.api.status.command.has,
                    color = { fg = "#EED49F" },
                },
                {
                    noice.api.status.mode.get,
                    cond = noice.api.status.mode.has,
                    color = { fg = "#EED49F" },
                },
                {
                    noice.api.status.search.get,
                    cond = noice.api.status.search.has,
                    color = { fg = "#EED49F" },
                },
            },
        }
    }

    vim.cmd.colorscheme "rose-pine"
end

return {
    init = init,
}
