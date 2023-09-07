local function set_vim_g()
    vim.g.mapleader = " "
    vim.g.netrw_browse_split = 0
    vim.g.netrw_banner = 0
    vim.g.netrw_winsize = 25
end

local function set_vim_o()
    local settings = {
        clipboard = 'unnamedplus',
        colorcolumn = 80,
        expandtab = true,
        scrolloff = 3,
        shiftwidth = 4,
        shortmess = vim.o.shortmess .. 'c',
        splitright = true,
        tabstop = 4,
        termguicolors = true,
        updatetime = 50,
    }

    for k, v in pairs(settings) do
        vim.o[k] = v
    end

    -- Not supported
    vim.cmd("set colorcolumn=80")
end

local function set_vim_wo()
    local settings = {
        number = true,
        relativenumber = true,
        wrap = false,
    }

    for k, v in pairs(settings) do
        vim.wo[k] = v
    end
end

local function set_vim_opt()
    vim.opt.list = true
    vim.opt.listchars:append "eol:↴"
end

local function set_vim_keymaps()
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)


end

local function init()
    set_vim_g()
    set_vim_o()
    set_vim_wo()
    set_vim_opt()
    set_vim_keymaps()
end

return {
    init = init,
}
