return {
  {
    "echasnovski/mini.move",
    version = false,
    config = function()
      require("mini.move").setup({
        options = {
          reindent_linewise = false,
        },
      })
    end,
  },
}
