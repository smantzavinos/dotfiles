return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown", "Avante" },
      })
    end,
    ft = { "markdown", "Avante" },
  }
}
