return {
  "neovim/nvim-lspconfig",
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Python: Pyright
    vim.lsp.config("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
      },
      capabilities = capabilities,
    })
    vim.lsp.enable("pyright")

    -- English / LaTeX / Markdown: LTeX Language Server
    -- Install separately, for example:
    --   brew install ltex-ls
    -- or put ltex-ls in your PATH.
    vim.lsp.config("ltex", {
      cmd = { "ltex-ls" },
      filetypes = { "tex", "bib", "markdown", "text", "plaintex" },
      capabilities = capabilities,

      get_language_id = function(_, filetype)
        if filetype == "tex" or filetype == "plaintex" then
          return "latex"
        elseif filetype == "bib" then
          return "bibtex"
        elseif filetype == "markdown" then
          return "markdown"
        else
          return "plaintext"
        end
      end,

      settings = {
        ltex = {
          language = "en-US",
          enabled = { "latex", "bibtex", "markdown", "plaintext" },
          checkFrequency = "edit",
          diagnosticSeverity = "warning",
          additionalRules = {
            enablePickyRules = true,
          },
          dictionary = {
            ["en-US"] = vim.fn.filereadable(vim.fn.expand("~/.config/ltex/dictionary.txt")) == 1
                and vim.fn.readfile(vim.fn.expand("~/.config/ltex/dictionary.txt"))
              or {},
          },
        },
      },
    })
    vim.lsp.enable("ltex")
  end,
}
