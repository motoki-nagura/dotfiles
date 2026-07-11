-- =========================================
-- Basic settings
-- =========================================
vim.g.python3_host_prog = "/Users/nagura/miniforge3/bin/python3"

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

vim.opt.hidden = true
vim.opt.wildmenu = true
vim.opt.showcmd = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.backspace = "indent,eol,start"
vim.opt.autoindent = true
vim.opt.startofline = false
vim.opt.ruler = true
vim.opt.laststatus = 2
vim.opt.confirm = true
vim.opt.mouse = "a"
vim.opt.cmdheight = 2
vim.opt.number = true
vim.opt.timeout = true
vim.opt.timeoutlen = 500
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- =========================================
-- Indentation
-- =========================================
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- =========================================
-- Appearance
-- =========================================
vim.opt.background = "dark"
vim.opt.scrolloff = 5
vim.opt.wildmode = "list:longest"
vim.opt.textwidth = 90
vim.opt.formatoptions:remove("t")

-- =========================================
-- lazy.nvim bootstrap
-- =========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Load plugin specifications from ~/.config/nvim/lua/plugins/*.lua.
    { import = "plugins" },

    -- Disable vim-slime even if it is still declared under lua/plugins/.
    { "jpalardy/vim-slime", enabled = false },

    -- Seamless navigation and resizing across Neovim splits and tmux panes.
    {
      "mrjones2014/smart-splits.nvim",
      version = ">=2.0.0",
      lazy = false,
      opts = {
        at_edge = "stop",
        multiplexer_integration = "tmux",
        default_amount = 3,
      },
      config = function(_, opts)
        local smart_splits = require("smart-splits")
        smart_splits.setup(opts)

        local map_opts = { silent = true }

        -- Move with Ctrl-w followed by h/j/k/l across Neovim and tmux.
        vim.keymap.set({ "n", "t" }, "<C-w>h", smart_splits.move_cursor_left,
          vim.tbl_extend("force", map_opts, { desc = "Move left" }))
        vim.keymap.set({ "n", "t" }, "<C-w>j", smart_splits.move_cursor_down,
          vim.tbl_extend("force", map_opts, { desc = "Move down" }))
        vim.keymap.set({ "n", "t" }, "<C-w>k", smart_splits.move_cursor_up,
          vim.tbl_extend("force", map_opts, { desc = "Move up" }))
        vim.keymap.set({ "n", "t" }, "<C-w>l", smart_splits.move_cursor_right,
          vim.tbl_extend("force", map_opts, { desc = "Move right" }))

        -- Resize Neovim windows or tmux panes with Alt-h/j/k/l.
        vim.keymap.set({ "n", "t" }, "<M-h>", smart_splits.resize_left,
          vim.tbl_extend("force", map_opts, { desc = "Resize left" }))
        vim.keymap.set({ "n", "t" }, "<M-j>", smart_splits.resize_down,
          vim.tbl_extend("force", map_opts, { desc = "Resize down" }))
        vim.keymap.set({ "n", "t" }, "<M-k>", smart_splits.resize_up,
          vim.tbl_extend("force", map_opts, { desc = "Resize up" }))
        vim.keymap.set({ "n", "t" }, "<M-l>", smart_splits.resize_right,
          vim.tbl_extend("force", map_opts, { desc = "Resize right" }))
      end,
    },
  },
})

-- =========================================
-- Autocommands
-- =========================================

-- Restore the cursor position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})

vim.api.nvim_create_autocmd("Syntax", {
  pattern = "f90",
  command = "source ~/.vim/syntax/fortran.vim",
})

-- LaTeX folding
vim.api.nvim_create_augroup("latex_folding", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "latex_folding",
  pattern = "tex",
  callback = function()
    vim.opt_local.foldmethod = "marker"
    vim.opt_local.foldmarker = "<<<,>>>"
  end,
})

-- Disable LSP document symbol highlighting.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      client.server_capabilities.documentHighlightProvider = false
    end
  end,
})

-- Notify when a file is reloaded from disk.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    print("File reloaded from disk")
  end,
})

-- =========================================
-- Commands and keymaps
-- =========================================
vim.api.nvim_create_user_command("RmBlanks", "g/^\\s\\+$/s/\\s\\+//", {})

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>n", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>p", vim.diagnostic.goto_prev)

-- Leave terminal insert mode with Esc.
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- =========================================
-- Diagnostics
-- =========================================
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- =========================================
-- Miscellaneous options
-- =========================================
vim.opt.foldmethod = "marker"

vim.opt.indentkeys:remove("0}")
vim.opt.indentkeys:remove("0]")
vim.opt.indentkeys:remove("&")
vim.opt.indentkeys:remove("]")
vim.opt.indentkeys:remove("}")

-- =========================================
-- Auto-reload for Codex
-- =========================================
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})
