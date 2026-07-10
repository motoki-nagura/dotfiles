return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.diagnostics.vale.with({
          filetypes = { "tex", "markdown", "text" },
          extra_args = {
            "--config",
            vim.fn.expand("~/.config/vale/.vale.ini"),
          },
        }),
      },
    })
  end,
}
