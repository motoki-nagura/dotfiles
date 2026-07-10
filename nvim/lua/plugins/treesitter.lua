return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({ "python", "lua", "vim", "vimdoc" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
