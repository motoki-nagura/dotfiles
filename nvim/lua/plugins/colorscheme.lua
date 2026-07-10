return {
  "joshdick/onedark.vim",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme onedark")

    -- Treesitter colors.
    vim.api.nvim_set_hl(0, "@parameter", { fg = "#ffaf00" })
    vim.api.nvim_set_hl(0, "@property", { fg = "#87afaf" })
    vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#ff5f87" })

    vim.api.nvim_set_hl(0, "@parameter.python", { fg = "#ffaf00" })
    vim.api.nvim_set_hl(0, "@property.python", { fg = "#87afaf" })

    vim.api.nvim_set_hl(0, "@keyword", { fg = "#c678dd" })
    vim.api.nvim_set_hl(0, "@type", { fg = "#e5c07b" })

    vim.api.nvim_set_hl(0, "Comment", { fg = "#9aa0a6" })
    vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })

    vim.api.nvim_set_hl(0, "@function.call", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "@function.builtin", { fg = "#e5c07b" })

    vim.api.nvim_set_hl(0, "@function.python", { fg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "@variable.python", { fg = "#4db6ac" })

    vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#000000" })

    -- Inactive status line color.
    vim.api.nvim_set_hl(0, "StatusLineNC", {
      fg = "#e5c07b",
      bg = "#3a3f4b",
    })
  end,
}
