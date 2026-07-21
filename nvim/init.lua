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

    -- zoxide integration. Provides :Z and :Zi commands.
    { "nanotee/zoxide.vim" },

    -- Disable vim-slime even if it is still declared under lua/plugins/.
    { "jpalardy/vim-slime", enabled = false },
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

-- In Terminal mode, first leave terminal-input mode and then move windows.
for _, direction in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set(
    "t",
    "<C-w>" .. direction,
    "<C-\\><C-n><C-w>" .. direction,
    { silent = true, desc = "Move to window " .. direction }
  )
end

-- Automatically enter Terminal mode when moving into a terminal window.
-- Schedule startinsert so it runs after the window/buffer switch has completed.
local terminal_insert_group =
  vim.api.nvim_create_augroup("terminal_auto_insert", { clear = true })

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "WinEnter" }, {
  group = terminal_insert_group,
  pattern = "*",
  callback = function(args)
    vim.schedule(function()
      -- The user may have moved again before the scheduled callback runs.
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end
      if vim.api.nvim_get_current_buf() ~= args.buf then
        return
      end
      if vim.bo[args.buf].buftype == "terminal" then
        vim.cmd("startinsert")
      end
    end)
  end,
})

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
