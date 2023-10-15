local copilot = require 'copilot'
local lspconfig = require 'lspconfig'
local ht = require 'haskell-tools'
local rust_tools = require 'rust-tools'
local treesitter = require 'nvim-treesitter.configs'
local treesitter_context = require 'treesitter-context'
local cmp = require 'cmp'
local null_ls = require 'null-ls'

local function autocmd(args)
    local event = args[1]
    local group = args[2]
    local callback = args[3]

    vim.api.nvim_create_autocmd(event, {
        group = group,
        buffer = args[4],
        callback = function()
            callback()
        end,
        once = args.once,
    })
end

local function on_attach(client, buffer)
    local augroup_highlight = vim.api.nvim_create_augroup("custom-lsp-references", { clear = true })
    local autocmd_clear = vim.api.nvim_clear_autocmds

    local opts = { buffer = buffer, remap = false }

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[buffer].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)

    if client.server_capabilities.documentHighlightProvider then
        autocmd_clear { group = augroup_highlight, buffer = buffer }
        autocmd { "CursorHold", augroup_highlight, vim.lsp.buf.document_highlight, buffer }
        autocmd { "CursorMoved", augroup_highlight, vim.lsp.buf.clear_references, buffer }
        autocmd { "TextYankPost", augroup_highlight, function() vim.highlight.on_yank { timeout = 40 } end, buffer }
    end
end

local function init()
    -- Completion setup
    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "friendly-snippets" },
            { name = "luasnip" },
        }, { { name = "buffer" } }, { { name = "path" } })
    })

    -- Copilot setup
    copilot.setup {
        suggestion = {
            auto_trigger = true,
            keymap = {
                accept = "<C-y>",
            }
        }
    }


    null_ls.setup({
        sources = {
            null_ls.builtins.formatting.prettier.with {
                extra_filetypes = { "svelte" }
            },
            null_ls.builtins.formatting.terraform_fmt.with({
                extra_filetypes = { "hcl" },
            }),
            null_ls.builtins.formatting.alejandra
        },
    })

    ht.setup {
        tools = {
            hover = {
                disable = true
            }
        },
        hls = {
            filetypes = { 'haskell', 'lhaskell', 'cabal' },
            on_attach = function(client, bufnr)
                local def_opts = { noremap = true, silent = true, }
                on_attach(client, bufnr)
                local opts = vim.tbl_extend('keep', def_opts, { buffer = bufnr, })
                -- haskell-language-server relies heavily on codeLenses,
                -- so auto-refresh (see advanced configuration) is enabled by default
                vim.keymap.set('n', '<leader>ca', vim.lsp.codelens.run, opts)
                -- Hoogle search for the type signature of the definition under the cursor
                vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
                -- Evaluate all code snippets
                vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
                -- Toggle a GHCi repl for the current package
                vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
                -- Toggle a GHCi repl for the current buffer
                vim.keymap.set('n', '<leader>rf', function()
                    ht.repl.toggle(vim.api.nvim_buf_get_name(0))
                end, def_opts)
                vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
            end,
        },
    }


    -- Rust specific setup
    rust_tools.setup {
        server = {
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        buildScripts = {
                            enable = true,
                        },
                    },
                    diagnostics = {
                        enable = false,
                    },
                    files = {
                        excludeDirs = { ".direnv", ".git" },
                        watcherExclude = { ".direnv", ".git" },
                    },
                },
            },
            on_attach = on_attach,
        },
    }

    local language_servers = {
        bashls = {},
        cssls = {},
        diagnosticls = {
            filetypes = { "python" },
            init_options = {
                filetypes = {
                    python = "black"
                },
                formatFiletypes = {
                    python = { "black" }
                },
                formatters = {
                    black = {
                        command = "black",
                        args = { "--quiet", "-" },
                        rootPatterns = { "pyproject.toml" },
                    },
                },
            }
        },
        dockerls = {},
        gopls = {
            settings = {
                gopls = {
                    gofumpt = true,
                },
            },
        },
        hls = {},
        html = {},
        jsonls = {},
        jsonnet_ls = {},
        lua_ls = {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' }
                    },
                    runtime = {
                        version = 'LuaJIT',
                    },
                    telemetry = {
                        enable = false,
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                },
            }
        },
        nil_ls = {
        },
        purescriptls = {
            settings = {
                purescript = {
                    formatter = "purs-tidy"
                }
            },
            root_dir = function(path)
                local util = require('lspconfig.util')
                if path:match('/.spago/') then
                    return nil
                end
                return util.root_pattern('bower.json', 'psc-package.json', 'spago.dhall', 'flake.nix', 'shell.nix')(path);
            end,
        },
        pyright = {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true
                    },
                },
            },
        },
        svelte = {},
        tailwindcss = {},
        terraformls = {},
        tsserver = {},
        yamlls = {
            settings = {
                yaml = {
                    keyOrdering = false,
                },
            },
        },
    }

    -- Initialize servers
    for server, server_config in pairs(language_servers) do
        local config = { on_attach = on_attach }

        if server_config then
            for k, v in pairs(server_config) do
                config[k] = v
            end
        end

        lspconfig[server].setup(config)
    end

    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

    treesitter.setup {
        highlight = { enable = true },
        indent = { enable = true },
        rainbow = { enable = true },
    }

    treesitter_context.setup()
end

return {
    init = init,
}
