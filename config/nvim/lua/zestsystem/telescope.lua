local telescope = require 'telescope'

local function init()
    telescope.setup {
        defaults = {
            file_ignore_patterns = {
                "node_modules/.*",
                "secret.d/.*",
                "%.pem"
            }
        }
    }

    telescope.load_extension('notify')

    local map = vim.api.nvim_set_keymap

    local options = { noremap = true }

    -- Builtin
    map('n', '<leader>pg', '<CMD>lua require("telescope.builtin").git_files{}<CR>', options)
    map('n', '<leader>pf', '<CMD>lua require("telescope.builtin").find_files{ hidden = true }<CR>', options)
    map('n', '<leader>ps', '<CMD>lua require("telescope.builtin").live_grep()<CR>', options)
    map('n', '<leader>pb', '<CMD>lua require("telescope.builtin").buffers()<CR>', options)
    map('n', '<leader>ph', '<CMD>lua require("telescope.builtin").help_tags()<CR>', options)
    map('n', '<leader>pd', '<CMD>lua require("telescope.builtin").diagnostics()<CR>', options)
    map('n', '<leader>pr', '<CMD>lua require("telescope.builtin").registers()<CR>', options)

    -- Language Servers
    map('n', '<leader>lsd', '<CMD>lua require("telescope.builtin").lsp_definitions{}<CR>', options)
    map('n', '<leader>lsi', '<CMD>lua require("telescope.builtin").lsp_implementations{}<CR>', options)
    map('n', '<leader>lsl', '<CMD>lua require("telescope.builtin").lsp_code_actions{}<CR>', options)
    map('n', '<leader>lst', '<CMD>lua require("telescope.builtin").lsp_type_definitions{}<CR>', options)

    -- Extensions
    map('n', '<leader>fn', '<CMD>lua require("telescope").extensions.notify.notify()<CR>', options)
end

return {
    init = init,
}
