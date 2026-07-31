return {
  {
    "MeanderingProgrammer/render-markdown.nvim",

    -- filetypeによる遅延ロードをやめ、起動時に読み込む
    lazy = false,

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },

    opts = {
      file_types = { "markdown" },
    },
  },
}
