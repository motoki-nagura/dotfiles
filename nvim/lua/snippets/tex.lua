local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local sn = ls.snippet_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local line_begin = require("luasnip.extras.expand_conditions").line_begin


-- ========================
-- Matrix generator
-- Usage:
--   pmat2x2 -> \begin{pmatrix} ... \end{pmatrix}
--   bmat3x3 -> \begin{bmatrix} ... \end{bmatrix}
-- ========================
local function matrix_nodes(_, snip)
  local rows = tonumber(snip.captures[1])
  local cols = tonumber(snip.captures[2])

  if not rows or not cols or rows < 1 or cols < 1 then
    return sn(nil, { i(1) })
  end

  local nodes = {}
  local jump_index = 1

  for r = 1, rows do
    for c = 1, cols do
      table.insert(nodes, i(jump_index))
      jump_index = jump_index + 1

      if c < cols then
        table.insert(nodes, t(" & "))
      end
    end

    if r < rows then
      table.insert(nodes, t({ " \\\\", "" }))
    end
  end

  return sn(nil, nodes)
end

return {
  -- ========================
  -- Math mode auto ($$)
  -- ========================
  s({ trig = "mm", name = "inline math", wordTrig = false },
    fmt("${{{}}}${}", { i(1), i(0) })
  ),

  -- ========================
  -- Fractions / powers
  -- ========================
  s({ trig = "ff", name = "frac", wordTrig = false },
    fmt("\\frac{{{}}}{{{}}}{}", { i(1), i(2), i(0) })
  ),

  s({ trig = "sq", name = "sqrt", wordTrig = false },
    fmt("\\sqrt{{{}}}{}", { i(1), i(0) })
  ),

  -- ========================
  -- Subscripts / superscripts
  -- ========================
  s({ trig = "__", name = "subscript", wordTrig = false },
    fmt("_{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "^^", name = "superscript", wordTrig = false },
    fmt("^{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "ovl", name = "overline", wordTrig = false },
    fmt("\\overline{{{}}}{}", { i(1), i(0) })
  ),

  -- ========================
  -- Greek letters
  -- ========================
  s({ trig = ";a",   name = "alpha", wordTrig = false }, { t("\\alpha") }),
  s({ trig = ";b",   name = "beta",  wordTrig = false }, { t("\\beta") }),
  s({ trig = ";d",   name = "delta", wordTrig = false }, { t("\\delta") }),
  s({ trig = ";e",   name = "eta",   wordTrig = false }, { t("\\eta") }),
  s({ trig = ";f",   name = "phi",   wordTrig = false }, { t("\\phi") }),
  s({ trig = ";g",   name = "gamma", wordTrig = false }, { t("\\gamma") }),
  s({ trig = ";k",   name = "kappa", wordTrig = false }, { t("\\kappa") }),
  s({ trig = ";l",   name = "lambda",wordTrig = false }, { t("\\lambda") }),
  s({ trig = ";m",   name = "mu",    wordTrig = false }, { t("\\mu") }),
  s({ trig = ";o",   name = "omega", wordTrig = false }, { t("\\omega") }),
  s({ trig = ";p",   name = "pi",    wordTrig = false }, { t("\\pi") }),
  s({ trig = ";ph",  name = "phi",   wordTrig = false }, { t("\\phi") }),
  s({ trig = ";psi", name = "psi",   wordTrig = false }, { t("\\psi") }),
  s({ trig = ";r",   name = "rho",   wordTrig = false }, { t("\\rho") }),
  s({ trig = ";s",   name = "sigma", wordTrig = false }, { t("\\sigma") }),
  s({ trig = ";t",   name = "theta", wordTrig = false }, { t("\\theta") }),
  s({ trig = ";x",   name = "xi",    wordTrig = false }, { t("\\xi") }),

  s({ trig = ";D", name = "Delta", wordTrig = false }, { t("\\Delta") }),
  s({ trig = ";O", name = "Omega", wordTrig = false }, { t("\\Omega") }),

  s({ trig = ";vphi", name = "varphi",     wordTrig = false }, { t("\\varphi") }),
  s({ trig = ";veps", name = "varepsilon", wordTrig = false }, { t("\\varepsilon") }),

  -- ========================
  -- Brackets
  -- ========================
  s({ trig = "lr", name = "left right", wordTrig = false },
    fmt("\\left( {} \\right){}", { i(1), i(0) })
  ),

  s({ trig = "lrs", name = "left right []", wordTrig = false },
    fmt("\\left[ {} \\right]{}", { i(1), i(0) })
  ),

  s({ trig = "lrc", name = "left right {}", wordTrig = false },
    fmt("\\left\\{{ {} \\right\\}}{}", { i(1), i(0) })
  ),

  s({ trig = "lra", name = "left right <>", wordTrig = false },
    fmt("\\left< {} \\right>{}", { i(1), i(0) })
  ),

  s({ trig = "lr|", name = "left right ||", wordTrig = false },
    fmt("\\left| {} \\right|{}", { i(1), i(0) })
  ),

  -- ========================
  -- Cases
  -- ========================
  s({ trig = "cas", name = "cases", wordTrig = false },
    fmt([[
\begin{cases}
<> & <> \\
<> & <>
\end{cases}
<>]], { i(1), i(2), i(3), i(4), i(0) }, { delimiters = "<>" })
  ),

  -- ========================
  -- Matrix generator
  -- ========================
  s({ trig = "pmat(%d+)x(%d+)", name = "pmatrix generator", regTrig = true, wordTrig = false },
    {
      t("\\begin{pmatrix}"),
      t({ "", "" }),
      d(1, matrix_nodes),
      t({ "", "\\end{pmatrix}" }),
      i(0),
    }
  ),

  s({ trig = "bmat(%d+)x(%d+)", name = "bmatrix generator", regTrig = true, wordTrig = false },
    {
      t("\\begin{bmatrix}"),
      t({ "", "" }),
      d(1, matrix_nodes),
      t({ "", "\\end{bmatrix}" }),
      i(0),
    }
  ),

  s({ trig = "vmat(%d+)x(%d+)", name = "vmatrix generator", regTrig = true, wordTrig = false },
    {
      t("\\begin{vmatrix}"),
      t({ "", "" }),
      d(1, matrix_nodes),
      t({ "", "\\end{vmatrix}" }),
      i(0),
    }
  ),

  -- ========================
  -- Align environment
  -- ========================
  s({ trig = "ali", name = "align", wordTrig = false },
    fmt([[
\begin{align}
  <>
\end{align}
<>]], { i(1), i(0) }, { delimiters = "<>" })
  ),

  -- ========================
  -- Text in math
  -- ========================
  s({ trig = "text", name = "text", wordTrig = false },
    fmt("\\text{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "textcolor", name = "text color", wordTrig = false },
    fmt("\\textcolor{{{}}}{{{}}}{}", { i(1), i(2), i(0) })
  ),

  -- ========================
  -- Derivatives & Integrals
  -- ========================
  s({ trig = "pt", name = "partial",  wordTrig = false }, { t("\\pt ") }),

  s({ trig = "pd", name = "partial derivative" },
    fmt("\\frac{{\\pt {}}}{{\\pt {}}}{}", { i(1, "f"), i(2, "x"), i(0) }),
    { condition = line_begin }
  ),

  s({ trig = "pdd", name = "second partial derivative" },
    fmt("\\frac{{\\pt^2 {}}}{{\\pt {}^2}}{}", { i(1, "f"), i(2, "x"), i(0) }),
    { condition = line_begin }
  ),

  s({ trig = "pdc", name = "mixed partial derivative" },
    fmt("\\frac{{\\pt^2 {}}}{{\\pt {} \\pt {}}}{}", { i(1, "f"), i(2, "x"), i(3, "y"), i(0) }),
    { condition = line_begin }
  ),

  s({ trig = "int", name = "integral", wordTrig = false },
    fmt([[
\int_{{{}}}^{{{}}} {} \, d{}
{}]], { i(1, "a"), i(2, "b"), i(3), i(4, "x"), i(0) })
  ),

  -- ========================
  -- Vector operations
  -- ========================
  s({ trig = "vd", name = "dot product", wordTrig = false },
    fmt("{} \\cdot {}{}", { i(1, "\\mathbf{A}"), i(2, "\\mathbf{B}"), i(0) })
  ),

  s({ trig = "vc", name = "cross product", wordTrig = false },
    fmt("{} \\times {}{}", { i(1, "\\mathbf{A}"), i(2, "\\mathbf{B}"), i(0) })
  ),

  s({ trig = "nabla", name = "nabla",  wordTrig = false }, { t("\\nabla ") }),

  -- ========================
  -- Fonts
  -- ========================
  s({ trig = "mfr", name = "mathfrak {}", wordTrig = false },
    fmt("\\mathfrak{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "mbb", name = "mathbb {}", wordTrig = false },
    fmt("\\mathbb{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "msf", name = "mathsf {}", wordTrig = false },
    fmt("\\mathsf{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "mcl", name = "mathcal {}", wordTrig = false },
    fmt("\\mathcal{{{}}}{}", { i(1), i(0) })
  ),

    s(
    { trig = "bm", name = "\\bm{}", wordTrig = false },
    fmta("\\bm{<>}<>", {
      i(1),
      i(0),
    })
  ),

  -- ========================
  -- Set symbols
  -- ========================
  s({ trig = "inn",      name = "in",       wordTrig = false }, { t("\\in ") }),
  s({ trig = "subset",   name = "subset",   wordTrig = false }, { t("\\subset ") }),
  s({ trig = "subseteq", name = "subseteq", wordTrig = false }, { t("\\subseteq ") }),
  s({ trig = "oplus",    name = "oplus",    wordTrig = false }, { t("\\oplus ") }),
  s({ trig = "cap",      name = "cap",      wordTrig = false }, { t("\\cap ") }),
  s({ trig = "cup",      name = "cup",      wordTrig = false }, { t("\\cup ") }),
  s({ trig = "preceq",   name = "preceq",   wordTrig = false }, { t("\\preceq ") }),
  s({ trig = "succeq",   name = "succeq",   wordTrig = false }, { t("\\succeq ") }),

  -- ========================
  -- Trigonometric and other functions
  -- ========================
  s({ trig = "cos", name = "cosine",  wordTrig = false }, { t("\\cos") }),
  s({ trig = "sin", name = "sine",    wordTrig = false }, { t("\\sin") }),
  s({ trig = "tan", name = "tangent", wordTrig = false }, { t("\\tan") }),

  s({ trig = ";e%^", regTrig = true }, fmta("e^{<>}", {i(1),}) ),  -- ;e^ → e^{}
  s({ trig = ";exp" }, fmta("\\exp\\left[ <> \\right]", {i(1),})), -- ;exp → \exp\left[ \right]

  -- ========================
  -- Other symbols
  -- ========================
  s({ trig = "pm",      name = "plus minus",               wordTrig = false }, { t("\\pm ") }),
  s({ trig = "rarw",    name = "right arrow",              wordTrig = false }, { t("\\rightarrow ") }),
  s({ trig = "cdot",    name = "cdot",                     wordTrig = false }, { t("\\cdot ") }),
  s({ trig = "cdots",   name = "cdots",                    wordTrig = false }, { t("\\cdots ") }),
  s({ trig = "vdots",   name = "vdots",                    wordTrig = false }, { t("\\vdots ") }),
  s({ trig = "neq",     name = "not equal to",             wordTrig = false }, { t("\\neq ") }),
  s({ trig = "ge",      name = "greater than or equal to", wordTrig = false }, { t("\\ge ") }),
  s({ trig = "ge",      name = "greater than or equal to", wordTrig = false }, { t("\\ge ") }),
  s({ trig = "le",      name = "less than or equal to",    wordTrig = false }, { t("\\le ") }),
  s({ trig = "times",   name = "times",                    wordTrig = false }, { t("\\times ") }),
  s({ trig = "infty",   name = "infinity",                 wordTrig = false }, { t("\\infty ") }),
  s({ trig = "because", name = "because",                  wordTrig = false }, { t("\\because ") }),

  s({ trig = "sum", name = "sum", wordTrig = false },
    fmt([[
\sum_{{{}}}^{{{}}} {} {}]], { i(1), i(2), i(3), i(0) })
  ),

  s({ trig = "prod", name = "product", wordTrig = false },
    fmt([[
\prod_{{{}}}^{{{}}} {}]], { i(1), i(2), i(3) })
  ),

  s({ trig = "hat", name = "hat", wordTrig = false },
    fmt("\\hat{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "tilde", name = "tilde", wordTrig = false },
    fmt("\\tilde{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "check", name = "check", wordTrig = false },
    fmt("\\check{{{}}}{}", { i(1), i(0) })
  ),

  -- ========================
  -- Misc
  -- ========================
  s({ trig = "quad",     name = "quad",         wordTrig = false }, { t("\\quad ") }),
  s({ trig = ";qq",      name = "qquad",        wordTrig = false }, { t("\\qquad ") }),
  s({ trig = "nonumber", name = "no number",    wordTrig = false }, { t("\\nonumber ") }),
  s({ trig = "noindent", name = "no indent",    wordTrig = false }, { t("\\noindent ") }),
  s({ trig = ";ds",      name = "displaystyle", wordTrig = false }, { t("\\displaystyle ") }),
  s({ trig = "prime",    name = "prime",        wordTrig = false }, { t("\\prime ") }),
  s({ trig = "textbf",   name = "text bold",    wordTrig = false }, fmt("\\textbf{{{}}}{}", { i(1), i(0) }) ),
  s({ trig = "vspace",   name = "vspace",       wordTrig = false }, fmt("\\vspace{{{}}}{}", { i(1), i(0) }) ),

  -- ========================
  -- Non LaTeX symbols
  -- ========================
  s({ trig = "para", name = "paragraph", wordTrig = true },
    fmt("\\paragraph{{{}}}{}", { i(1), i(0) })
  ),

  s({ trig = "prop", name = "Proposition", wordTrig = false }, { t("Proposition ") }),

  s({ trig = "<<", name = "fold marker <<<", wordTrig = false },
    fmt("%<<<{}{}", { i(1), i(0) })
  ),

  s({ trig = ">>", name = "fold marker >>>", wordTrig = false },
    fmt("%>>>{}{}", { i(1), i(0) })
  ),

}
