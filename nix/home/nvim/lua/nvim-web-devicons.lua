return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require('nvim-web-devicons').setup({
        strict = true,
        override_by_filename = {
         [".gitignore"] = {
           icon = "",
           color = "#f1502f",
           name = "Gitignore"
         }
        },
        override_by_extension = {
         ["log"] = {
           icon = "",
           color = "#81e043",
           name = "Log"
         }
        }
      })
      
      -- Web Devicons wrapper. Called from startify config.
      function _G.webDevIcons(path)
        local filename = vim.fn.fnamemodify(path, ':t')
        local extension = vim.fn.fnamemodify(path, ':e')
        return require('nvim-web-devicons').get_icon(filename, extension, { default = true })
      end
    end
  }
}
