return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "folke/neodev.nvim",
  },
  config = function()
    -- Setup neovim lua configuration
    require("neodev").setup()
    
    local lspconfig = require('lspconfig')

    -- nvim-cmp supports additional completion capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.ts_ls.setup{
      capabilities = capabilities,
    }

    lspconfig.svelte.setup {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- Add your custom on_attach logic here, if needed
        -- For example, you can set keybindings for LSP features
      end,
      flags = {
        debounce_text_changes = 150,
      }
    }

    lspconfig.nixd.setup({
      capabilities = capabilities,
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
  end
}
