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

-- Shared LSP capabilities for nvim-cmp.
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- =========================================
-- Plugins
-- =========================================
require("lazy").setup({
  -- LaTeX support
  {
    "lervag/vimtex",
  },

  -- Color scheme
  {
    "joshdick/onedark.vim",
  },

  -- Python highlighting plugin kept disabled.
  {
    "numirias/semshi",
    enabled = false,
    build = ":UpdateRemotePlugins",
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "python", "lua", "vim", "vimdoc" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Python: Pyright
      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = {
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          ".git",
        },
        capabilities = lsp_capabilities,
      })
      vim.lsp.enable("pyright")

      -- English / LaTeX / Markdown: LTeX Language Server
      -- Install separately, for example:
      --   brew install ltex-ls
      -- or put ltex-ls in your PATH.
      vim.lsp.config("ltex", {
        cmd = { "ltex-ls" },
        filetypes = { "tex", "bib", "markdown", "text", "plaintex" },
        capabilities = lsp_capabilities,

        get_language_id = function(_, filetype)
          if filetype == "tex" or filetype == "plaintex" then
            return "latex"
          elseif filetype == "bib" then
            return "bibtex"
          elseif filetype == "markdown" then
            return "markdown"
          else
            return "plaintext"
          end
        end,

        settings = {
          ltex = {
            language = "en-US",
            enabled = { "latex", "bibtex", "markdown", "plaintext" },
            checkFrequency = "edit",
            diagnosticSeverity = "warning",
            additionalRules = {
              enablePickyRules = true,
            },
            dictionary = {
              ["en-US"] = vim.fn.filereadable(vim.fn.expand("~/.config/ltex/dictionary.txt")) == 1
                  and vim.fn.readfile(vim.fn.expand("~/.config/ltex/dictionary.txt"))
                or {},
            },
          },
        },
      })
      vim.lsp.enable("ltex")
    end,
  },

  -- Vale diagnostics through none-ls
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.diagnostics.vale.with({
            filetypes = { "tex", "markdown", "text" },
            extra_args = {
              "--config",
              vim.fn.expand("~/.vale.ini"),
            },
          }),
        },
      })
    end,
  },

  -- Completion and snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = "~/.config/nvim/lua/snippets",
      })

      luasnip.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        sources = cmp.config.sources({
          { name = "luasnip", priority = 1000 },
          { name = "nvim_lsp", priority = 500 },
        }),

        preselect = cmp.PreselectMode.None,

        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },

        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            elseif cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
      })
    end,
  },
})

-- =========================================
-- Plugin configuration
-- =========================================

-- VimTeX
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_view_method = "skim"

-- Python
vim.g.python_highlight_all = 1

-- semshi settings kept for compatibility, although the plugin is disabled.
vim.g["semshi#simplify_markup"] = false
vim.g["semshi#mark_selected_nodes"] = 0
vim.cmd([[
highlight semshiLocal guifg=#5fd7ff
highlight semshiParameter guifg=#ffaf00
highlight semshiAttribute guifg=#87afaf
highlight semshiSelf guifg=#ff5f87
]])

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

-- Filetypes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.f90",
  command = "set filetype=f90",
})

vim.api.nvim_create_autocmd("Syntax", {
  pattern = "f90",
  command = "source ~/.vim/syntax/fortran.vim",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.jnl",
  command = "set filetype=ferret",
})

vim.api.nvim_create_autocmd("Syntax", {
  pattern = "ferret",
  command = "source ~/.vim/syntax/ferret.vim",
})

-- Run shortcuts
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.keymap.set("n", "<leader>r", ":w<CR>:!python %<CR>", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "julia",
  callback = function()
    vim.keymap.set("n", "<leader>r", ":w<CR>:!julia %<CR>", { buffer = true })
  end,
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
vim.opt.errorformat = "%E%f:%l:%c:,%E%f:%l:,%C,%C%p%*[0123456789^],%ZError:\\ %m,%C%.%#"
vim.opt.foldmethod = "marker"

vim.opt.indentkeys:remove("0}")
vim.opt.indentkeys:remove("&")
vim.opt.indentkeys:remove("]")
vim.opt.indentkeys:remove("}")

-- =========================================
-- Color scheme and highlights
-- =========================================
vim.cmd("colorscheme onedark")

-- Treesitter colors similar to the old Semshi palette.
vim.api.nvim_set_hl(0, "@parameter", { fg = "#ffaf00" })
vim.api.nvim_set_hl(0, "@property", { fg = "#87afaf" })
vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#ff5f87" })

vim.api.nvim_set_hl(0, "@parameter.python", { fg = "#ffaf00" })
vim.api.nvim_set_hl(0, "@property.python", { fg = "#87afaf" })

vim.api.nvim_set_hl(0, "@keyword", { fg = "#c678dd" })
vim.api.nvim_set_hl(0, "@type", { fg = "#e5c07b" })

vim.api.nvim_set_hl(0, "Comment", { fg = "#9aa0a6" })
vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })

vim.api.nvim_set_hl(0, "@function.call", { fg = "#61afef" })
vim.api.nvim_set_hl(0, "@function.builtin", { fg = "#e5c07b" })

vim.api.nvim_set_hl(0, "@function.python", { fg = "#61afef", bold = true })
vim.api.nvim_set_hl(0, "@variable.python", { fg = "#4db6ac" })

vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#000000" })

-- Inactive status line color.
vim.api.nvim_set_hl(0, "StatusLineNC", {
  fg = "#e5c07b",
  bg = "#3a3f4b",
})
