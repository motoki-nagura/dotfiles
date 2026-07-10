return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_python_ipython = 1
    vim.g.slime_default_config = {
      socket_name = "default",
      target_pane = ":.2",
    }
  end,
  config = function()
    vim.keymap.set("v", "<leader>rs", "<Plug>SlimeRegionSend", {
      desc = "Send selection to IPython",
    })

    vim.keymap.set("n", "<leader>rp", "<Plug>SlimeParagraphSend", {
      desc = "Send paragraph to IPython",
    })

    vim.keymap.set("n", "<leader>rr", "<Plug>SlimeLineSend", {
      desc = "Send current line to IPython",
    })

    vim.keymap.set("n", "<leader>ra", function()
      vim.cmd("%SlimeSend")
    end, {
      desc = "Send whole buffer to IPython",
    })
  end,
}
