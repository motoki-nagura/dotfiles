return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  config = function()
    local ls = require("luasnip")

    require("luasnip.loaders.from_lua").load({
      paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
    })

    local function feedkey(key)
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(key, true, true, true),
        "n",
        false
      )
    end

    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      else
        feedkey("<Tab>")
      end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      else
        feedkey("<S-Tab>")
      end
    end, { silent = true })
  end,
}
