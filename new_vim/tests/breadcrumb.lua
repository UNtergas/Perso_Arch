-- From repository root: nvim --headless -u NONE -l new_vim/tests/breadcrumb.lua
vim.opt.rtp:append(vim.fn.getcwd() .. '/new_vim/nvim')
local path=require('saga_breadcrumb').path
local function symbol(name,sl,sc,el,ec,children)
 return {name=name,kind=12,range={start={line=sl,character=sc},['end']={line=el,character=ec}},children=children}
end
local symbols={symbol('later',5,0,8,0),symbol('earlier',0,0,3,0)}
assert(path(symbols,1,1)[1].name=='earlier','Unsorted symbols')
assert(path(symbols,6,1)[1].name=='later')
assert(#path(symbols,3,0)==0,'Exclusive end range')
local inline={symbol('second',0,20,0,30),symbol('first',0,0,0,10)}
assert(path(inline,0,5)[1].name=='first','Same-line symbols')
assert(path(inline,0,25)[1].name=='second')
assert(#path(inline,0,15)==0,'Between same-line symbols')
local nested={symbol('class',0,0,10,0,{symbol('second',5,0,8,0),symbol('first',1,0,4,0)})}
local found=path(nested,2,1)
assert(#found==2 and found[1].name=='class' and found[2].name=='first','Nested unsorted symbols')
print('PASS: unsorted symbols, same-line scopes, nested symbols, and exclusive range boundaries')
