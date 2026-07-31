return {
  {
    "MeanderingProgrammer/render-markdown.nvim",

    -- Stop delayed load using filetype. Load when launched.
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
