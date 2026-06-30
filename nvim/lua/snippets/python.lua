local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  s("pri",
    fmt([[print("{} = ", {})]], {
      i(1, "value"),
      rep(1),
    })
  ),
}
