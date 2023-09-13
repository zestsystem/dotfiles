local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local function purescript()
    ls.add_snippets("purescript", {
        s("fa", {
            t("∀"),
        }),
    })
end

local function typescript()
    local effectSnippets = {
        s("gen_", {
            t("function* (_)"),
            t({ "{", "\t" }),
            i(0),
            t({ "", "}" }),
        }),
        s("egen_", {
            t("Effect.gen("),
            t("function* (_)"),
            t({ "{", "\t" }),
            i(0),
            t({ "", "}" }),
            t(")"),
        }),
        s("yield_", {
            t("yield* _"),
            t("("),
            i(0),
            t(")"),
        }),
        s("cyield_", {
            t("const "),
            i(1),
            t(" = "),
            t("yield* _"),
            t("("),
            i(0),
            t(")"),
        }),
        s("epipe", {
            t({ "pipe(", "\t" }),
            i(0),
            t({ "", ")" }),
        }),
    }

    ls.add_snippets("javascript", effectSnippets)
    ls.add_snippets("typescript", effectSnippets)
end

local function init()
    typescript()
    purescript()
end

return {
    init = init
}
