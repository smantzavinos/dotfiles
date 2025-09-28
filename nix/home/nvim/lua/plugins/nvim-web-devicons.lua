return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require('nvim-web-devicons').setup({
        -- globally enable "strict" selection of icons - icon will be looked up in
        -- different tables, first by filename, and if not found by extension; this
        -- prevents cases when file doesn't have any extension but still gets some icon
        -- because its name happened to match some extension (default to false)
        strict = true,
        -- same as `override` but specifically for overrides by extension
        -- takes effect when `strict` is true
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
