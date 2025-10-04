return {
  {
    "Shatur/neovim-ayu",
    config = function()
      vim.opt.termguicolors = true
      require('ayu').setup({
          mirage = true,
      })
      require('ayu').colorscheme()
    end
  }
}
