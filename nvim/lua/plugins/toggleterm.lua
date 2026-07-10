return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 120,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = false,
      persist_size = true,
      persist_mode = true,
      direction = "vertical",
      close_on_exit = true,
      shell = vim.o.shell,
    },
  },
}
