return {
  {
    "Vigemus/iron.nvim",
    ft = { "python" },
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      local ipython = "/Users/nagura/miniforge3/bin/ipython"
      if vim.fn.executable(ipython) ~= 1 then
        ipython = "ipython"
      end

      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = { ipython, "--no-autoindent" },
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
            },
          },
          repl_filetype = function(_, ft)
            return ft
          end,
          dap_integration = true,
          repl_open_cmd = view.split.vertical.botright(0.4),
        },
        keymaps = {
          toggle_repl = "<leader>rr",
          restart_repl = "<leader>rR",
          send_motion = "<leader>sc",
          visual_send = "<leader>sc",
          send_file = "<leader>sf",
          send_line = "<leader>sl",
          send_paragraph = "<leader>sp",
          send_until_cursor = "<leader>su",
          send_code_block = "<leader>sb",
          send_code_block_and_move = "<leader>sn",
          interrupt = "<leader>si",
          exit = "<leader>sq",
          clear = "<leader>cl",
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      })

      vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<CR>", { desc = "Focus Iron REPL" })
      vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<CR>", { desc = "Hide Iron REPL" })
    end,
  },
}
