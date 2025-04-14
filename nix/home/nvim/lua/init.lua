vim.g.mapleader = "\\" -- Set leader key to backslash
require("lazy").setup({
  performance = {
    reset_packpath = false,
    rtp = {
        reset = false,
      }
    },
  dev = {
    path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
    patterns = {""},
  },
  install = {
    -- Safeguard in case we forget to install a plugin with Nix
    missing = false,
  },
  spec = {
    { import = "plugins" },
    -- Add other plugins here
  }
})

vim.wo.number = true

vim.api.nvim_set_keymap('n', '<C-m>', ':tabnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-n>', ':tabprevious<CR>', {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', 'Y', 'yy', { noremap = true, silent = true })

local nvim_lsp = require("lspconfig")

nvim_lsp.nixd.setup({
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

-- Replace tabs with spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Enable autoread and set up autocommand for auto-reloading buffers
vim.opt.autoread = true
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
  command = "checktime"
})

-- Add keybinding to show diagnostics in a floating window
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { noremap = true, silent = true })

-- Add keybinding to copy all diagnostics to clipboard
vim.keymap.set('n', '<leader>D', function()
  local diagnostics = vim.diagnostic.get(0)
  local lines = {}
  for _, d in ipairs(diagnostics) do
    table.insert(lines, string.format("[%s] %s (line %d)", d.severity, d.message, d.lnum + 1))
  end
  local text = table.concat(lines, '\n')
  vim.fn.setreg('+', text) -- Copy to system clipboard
  print("Diagnostics copied to clipboard")
end, { noremap = true, silent = true })
