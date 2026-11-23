-- Better comments: every case must give the expected highlight group (or none).
-- Run from the repo root, inside the real config (it needs the treesitter parsers and the ftplugins):
--   nvim --headless -c "lua vim.wait(1200)" -c "luafile new_vim/tests/better_comments.lua" +qa
local bc = require("better_comments")
local cases = {
  { "lua", { "-- ! alert", "-- ? what", "-- * keep", "-- TODO later", "-- FIXME now", "-- -- old code", "--! not", "local x = 1 -- ! trailing", "-- plain comment", "local s = '-- ! in string'", "#!/bin/sh" },
    { "BetterCommentAlert", "BetterCommentQuery", "BetterCommentHighlight", "BetterCommentTodo", "BetterCommentTodo", "BetterCommentStrike", "none", "BetterCommentAlert", "none", "none", "none" } },
  { "javascript", { "// ! alert", "// ? q", "const a = 1 // * ok", "/// triple", "//! rust style", "// // gone", "const s = '// ! x'", "/**", " * ! block alert", " * normal doc line", " * * block highlight", " */", "x * ! y" },
    { "BetterCommentAlert", "BetterCommentQuery", "BetterCommentHighlight", "none", "none", "BetterCommentStrike", "none", "none", "BetterCommentAlert", "none", "BetterCommentHighlight", "none", "none" } },
  { "python", { "# ! alert", "x = 1  # ? why", "# TODO: fix", "#!/usr/bin/env python", "s = '# ! no'" },
    { "BetterCommentAlert", "BetterCommentQuery", "BetterCommentTodo", "none", "none" } },
  { "sh", { "# ! alert", "echo hi # * ok" }, { "BetterCommentAlert", "BetterCommentHighlight" } },
  { "rust", { "//! inner doc", "/// outer doc", "// ! alert", "let x = 1; // ? q" }, { "none", "none", "BetterCommentAlert", "BetterCommentQuery" } },
  -- Kotlin has no treesitter parser here: the guesses (own comment leader, quotes before it, an open /* block above) decide
  { "kotlin", { "// ! alert", "val x = 1 // ? q", 'val s = "// ! in a string"', "/**", " * ! doc alert", " * plain", " */", "val y = 2 * ! z" },
    { "BetterCommentAlert", "BetterCommentQuery", "none", "none", "BetterCommentAlert", "none", "none", "none" } },
  { "markdown", { "* item", "* ! looks like alert", "- ! x" }, { "none", "none", "none" } },
}
local total, bad = 0, 0
for _, c in ipairs(cases) do
  local ft, lines, want = c[1], c[2], c[3]
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = ft
  vim.wait(150)
  local ok = pcall(vim.treesitter.start, buf)
  if ok then pcall(function() vim.treesitter.get_parser(buf):parse(true) end) end
  for i, l in ipairs(lines) do
    local r = bc.scan(buf, i - 1, l)
    local got = r[1] and r[1].group or "none"
    total = total + 1
    if got ~= want[i] then bad = bad + 1; print(("FAIL [%s ts=%s] %q  got %s want %s"):format(ft, tostring(ok), l, got, want[i])) end
  end
end
print(("%d cases, %d failed"):format(total, bad))
