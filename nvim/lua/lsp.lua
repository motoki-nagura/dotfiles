-- Python (pyright)
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml" },
})

vim.lsp.enable("pyright")

-- LaTeX (texlab)
vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "latex" },
  root_markers = { ".git", ".latexmkrc" },
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
      },
      forwardSearch = {
        executable = "open",
        args = { "-a", "Skim", "%p" },
      },
    },
  },
})

vim.lsp.enable("texlab")
