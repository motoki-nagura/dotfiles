return {
  "lervag/vimtex",
  init = function()
    vim.g.vimtex_compiler_method = "latexmk"

    -- Use LuaLaTeX as latexmk's default engine.
    -- <leader>ll (normally \\ll) will compile with latexmk -lualatex.
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-lualatex",
    }

    -- macOS PDF viewer with SyncTeX support.
    vim.g.vimtex_view_method = "sioyek"
  end,
}
