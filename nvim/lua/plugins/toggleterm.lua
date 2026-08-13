return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = function(term)
        if term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.5) -- 50% of window width
        end
        return 15
      end,
      open_mapping = [[<C-\>]],
      direction = "vertical",
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = false,
      persist_size = true,
      persist_mode = true,
      close_on_exit = true,
      shell = vim.o.shell,
    },
  },
}
