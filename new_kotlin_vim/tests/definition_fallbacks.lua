-- Run from the repository root: nvim --headless -u NONE -l new_kotlin_vim/tests/definition_fallbacks.lua
vim.opt.rtp:append(vim.fn.getcwd() .. "/new_kotlin_vim/kvim")
local adapter = require("kotlin_definition")
local api = vim.api
local buf = api.nvim_create_buf(false, true)
api.nvim_buf_set_lines(buf, 0, -1, false, { "val name = résumé()" })
local params = { textDocument = { uri = vim.uri_from_bufnr(buf) }, position = { line = 0, character = 12 } }
local function location(file)
  return { uri = vim.uri_from_fname(file), range = { start = { line = 1, character = 0 }, ["end"] = { line = 1, character = 6 } } }
end
local function fixture()
  local requests, cancelled, replies, libraries, filled = {}, {}, {}, {}, {}
  local client = { offset_encoding = "utf-16" }
  function client:request(method, args, handler, source)
    requests[#requests + 1] = { method = method, args = args, handler = handler, buf = source }
    return true, #requests
  end
  function client:cancel_request(id) cancelled[id] = true; return true end
  adapter.attach(client, {
    fill_ranges = function(symbols)
      filled[#filled+1] = true
      for _,s in ipairs(symbols) do if s.location and not s.location.range then s.location.range = location("/tmp/unused").range end end
    end,
    library = function(word, source, encoding)
      libraries[#libraries + 1] = { word, source, encoding }
      return location("/tmp/library.kt")
    end,
  })
  local function start()
    return client:request("textDocument/definition", params, function(err, result, ctx)
      replies[#replies + 1] = { err = err, result = result, ctx = ctx }
    end, buf)
  end
  local function complete(id, result)
    local req = requests[id]
    req.handler(nil, result, { method = req.method, bufnr = req.buf, client_id = 1 })
  end
  return client, requests, cancelled, replies, libraries, filled, start, complete
end
local _, req, _, out, libs, _, start, complete = fixture()
start(); complete(1, { location("/tmp/direct.kt") })
assert(#req==1 and #libs==0 and out[1].result[1].uri:find("direct.kt"))
local _, req, _, out, libs, filled, start, complete = fixture()
start(); complete(1, {})
assert(req[2].method=="workspace/symbol" and req[2].args.query=="résumé")
complete(2, { { name="résumé", location={uri=vim.uri_from_fname("/tmp/workspace.kt")} }, {name="other", location=location("/tmp/other.kt")} })
assert(#libs==0 and #filled==1 and out[1].ctx.method=="textDocument/definition" and #out[1].result==1)
local _, _, _, out, libs, _, start, complete = fixture()
start(); complete(1, {})
api.nvim_set_current_buf(api.nvim_create_buf(false,true)) -- callbacks must keep the original source
complete(2,{})
assert(libs[1][1]=="résumé" and libs[1][2]==buf and out[1].result[1].uri:find("library.kt"))
local client, _, cancelled, out, _, _, start, complete = fixture()
local _, id = start(); complete(1,{})
client:cancel_request(id); complete(2,{})
assert(cancelled[1] and cancelled[2] and #out==0)
local _, _, _, out, _, _, start, complete = fixture()
local select = vim.ui.select
vim.ui.select = function(items, _, cb) cb(items[2]) end
start(); complete(1, {location("/tmp/first.kt"),location("/tmp/second.kt")})
vim.ui.select = select
assert(#out[1].result==1 and out[1].result[1].uri:find("second.kt"))
local _, _, _, out, libs, _, start, complete = fixture()
start(); complete(1,{})
api.nvim_buf_set_lines(buf,0,1,false,{"source changed"}); complete(2,{})
assert(#libs==0 and #out[1].result==0)
print("PASS: direct locations, Unicode symbols, workspace repair, library fallback, original buffer context, cancellation, multiple-location selection, stale results")
