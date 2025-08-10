return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require('lspconfig')

            -- Common LSP keybindings function
            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                
                -- Navigation
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
                
                -- Documentation and help
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                
                -- Code actions and refactoring
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
                
                -- Diagnostics
                vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, opts)
                vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            end

            -- TypeScript/JavaScript LSP
            lspconfig.ts_ls.setup{
                on_attach = on_attach,
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                settings = {
                    typescript = {
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
                    javascript = {
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
                },
            }

            -- Svelte LSP (handles all Svelte features including navigation)
            lspconfig.svelte.setup {
                on_attach = on_attach,
                flags = {
                    debounce_text_changes = 150,
                },
                settings = {
                    svelte = {
                        plugin = {
                            typescript = {
                                enable = true,
                                diagnostics = { enable = true },
                                hover = { enable = true },
                                documentSymbols = { enable = true },
                                completions = { enable = true },
                                findReferences = { enable = true },
                                definitions = { enable = true },
                                codeActions = { enable = true },
                                selectionRange = { enable = true },
                                rename = { enable = true }
                            }
                        }
                    }
                }
            }

            -- Nix LSP
            lspconfig.nixd.setup({
                cmd = { "nixd" },
                on_attach = on_attach,
                settings = {
                    nixd = {
                        nixpkgs = {
                            expr = "import <nixpkgs> { }",
                        },
                        formatting = {
                            command = { "nixfmt" },
                        },
                        options = {
                            nixos = {
                                expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options',
                            },
                            home_manager = {
                                expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
                            },
                        },
                    },
                },
            })
        end,
    },
}