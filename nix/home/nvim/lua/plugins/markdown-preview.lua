return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && yarn install",
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_preview_options = {
      mermaid = {
        enable = 1,
        theme = "default"
      }
    }
  end,
}
