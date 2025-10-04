-- config/options.lua
-- Core Vim options extracted from current config

-- Line numbers
vim.wo.number = true

-- Tab settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- File handling
vim.opt.autoread = true

-- UI settings
vim.opt.showmode = false

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Editor behavior
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Backup and swap files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Undo settings
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

-- Window splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Completion settings
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Update time for better user experience
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse support
vim.opt.mouse = "a"

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Sign column
vim.opt.signcolumn = "yes"

-- Color settings
vim.opt.termguicolors = true