return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require('lspconfig')

            -- TypeScript/JavaScript LSP
            lspconfig.ts_ls.setup{}

            -- Svelte LSP
            lspconfig.svelte.setup {
                on_attach = function(client, bufnr)
                    -- Add your custom on_attach logic here, if needed
                    -- For example, you can set keybindings for LSP features
                end,
                flags = {
                    debounce_text_changes = 150,
                }
            }

            -- Nix LSP
            lspconfig.nixd.setup({
                cmd = { "nixd" },
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