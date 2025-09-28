-- init.lua
-- Set leader keys early (before any plugin loading)
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

-- Load core Neovim configuration first
require("config.options")    -- Vim settings
require("config.keymaps")    -- Core keybindings  
require("config.autocmds")   -- Autocommands

-- Configure plugins directly without lazy.nvim
vim.schedule(function()
  -- Configure snacks.nvim
  local ok, snacks = pcall(require, "snacks")
  if ok then
    snacks.setup({
      input = { enabled = true },
      terminal = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      lazygit = { enabled = true },
      rename = { enabled = true },
      scratch = { enabled = true },
      toggle = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
    })
    
    -- Snacks keymaps
    vim.keymap.set("n", "<leader>st", function() snacks.terminal() end, { desc = "Open terminal" })
    vim.keymap.set("n", "<leader>sg", function() snacks.lazygit() end, { desc = "Open LazyGit" })
    vim.keymap.set("n", "<leader>gB", function() snacks.gitbrowse() end, { desc = "Git browse" })
    vim.keymap.set("n", "<leader>ss", function() snacks.scratch() end, { desc = "Open scratch buffer" })
    vim.keymap.set("n", "<leader>sz", function() snacks.zen() end, { desc = "Toggle zen mode" })
  end
  
  -- Configure colorscheme
  local ayu_ok, _ = pcall(require, "ayu")
  if ayu_ok then
    vim.cmd("colorscheme ayu-mirage")
  end
  
  -- Configure which-key
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.setup({})
    wk.add({
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>s", group = "Snacks/Search" },
      { "<leader>l", group = "LSP" },
      { "<leader>t", group = "Toggle" },
    })
  end
  
  -- Configure FzfLua
  local fzf_ok, fzf = pcall(require, "fzf-lua")
  if fzf_ok then
    fzf.setup({})
    
    -- FzfLua keymaps
    vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })
  end
  
  -- Configure TreeSitter
  local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
  if ts_ok then
    ts_configs.setup({
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
  
  -- Configure LSP
  local lsp_ok, lspconfig = pcall(require, "lspconfig")
  if lsp_ok then
    -- LSP keymaps
    local on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, opts)
    end
    
    -- Setup LSP servers
    lspconfig.lua_ls.setup({
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        },
      },
    })
    
    lspconfig.nixd.setup({ on_attach = on_attach })
  end
  
  -- Configure completion
  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    
    cmp.setup({
      snippet = luasnip_ok and {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      } or nil,
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end
  
  -- Configure Neo-tree
  local neotree_ok, neotree = pcall(require, "neo-tree")
  if neotree_ok then
    neotree.setup({
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_current",
      },
    })
    
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
  end
  
  print("Plugins configured successfully!")
end)

-- Load core Neovim configuration
require("config.options")    -- Vim settings
require("config.keymaps")    -- Core keybindings
require("config.autocmds")   -- Autocommands