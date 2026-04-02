require "nvchad.autocmds"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local config = require "configs.jdtls"
    require("jdtls").start_or_attach(config)
  end,
})
