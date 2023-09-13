local function harpoon()
    local mark = require "harpoon.mark"
    local ui = require "harpoon.ui"

    vim.keymap.set("n", "<leader><leader>g", mark.add_file)
    vim.keymap.set("n", "<leader><leader>f", ui.toggle_quick_menu)

    vim.keymap.set("n", "<leader>j", function()
        ui.nav_file(1)
    end)
    vim.keymap.set("n", "<leader>k", function()
        ui.nav_file(2)
    end)
    vim.keymap.set("n", "<leader>l", function()
        ui.nav_file(3)
    end)
    vim.keymap.set("n", "<leader>;", function()
        ui.nav_file(4)
    end)
end


local function init()
    harpoon()
end

return {
    init = init
}
