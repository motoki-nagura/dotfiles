-- Telescope keymap quick reference:
--   <leader>ff  Find files below the current working directory.
--   <leader>fg  Search text across files with ripgrep.
--   <leader>fb  Search open buffers; press Ctrl-D to close the selected buffer.
--   <leader>fh  Search Neovim and plugin help tags.
--   <leader>fd  Choose a directory, then find files below it.

return {
  "nvim-telescope/telescope.nvim",
  -- Track the current upstream version. The old 0.1.x branch uses a removed
  -- Treesitter API on recent Neovim versions.
  version = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Help tags",
    },
    {
      "<leader>fd",
      function()
        local directory = vim.fn.input(
          "Search directory: ",
          vim.fn.getcwd() .. "/",
          "dir"
        )

        if directory ~= "" then
          require("telescope.builtin").find_files({
            cwd = vim.fn.expand(directory),
          })
        end
      end,
      desc = "Find files in directory",
    },
  },
  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
      pickers = {
        buffers = {
          -- Keep the filename visible even when the full path is long.
          path_display = { "filename_first" },
          mappings = {
            i = {
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              ["<C-d>"] = actions.delete_buffer,
              ["dd"] = actions.delete_buffer,
            },
          },
        },
      },
    })
  end,
}
