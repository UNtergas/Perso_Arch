-- Requires the installed trial config. Run headlessly with +luafile and +qa! (no real project needed).
local api=vim.api
local crumbs=require('saga_breadcrumb')
local symbols=require('lspsaga.symbol.head')
local function symbol(name,sl,sc,el,ec)
 return {name=name,kind=12,range={start={line=sl,character=sc},['end']={line=el,character=ec}}}
end
local function make(name)
 local b=api.nvim_create_buf(true,false)
 api.nvim_buf_set_name(b,'/tmp/'..name)
 api.nvim_buf_set_lines(b,0,-1,false,{'one','two','three','four','five','six','seven','eight','nine','ten'})
 return b
end
local b1=make('breadcrumb-one.txt'); api.nvim_set_current_buf(b1)
local w1=api.nvim_get_current_win()
local b2=make('breadcrumb-two.txt')
local function update(buf,items)
 symbols[buf]={client_id=999999,symbols=items}
 api.nvim_exec_autocmds('User',{pattern='SagaSymbolUpdate',data={bufnr=buf,symbols=items}})
end
local function shown(win)
 return api.nvim_eval_statusline(vim.wo[win].winbar,{winid=win,use_winbar=true}).str
end
update(b1,{symbol('later',5,0,8,0),symbol('earlier',0,0,3,0)})
api.nvim_win_set_cursor(w1,{2,1})
assert(shown(w1):find('earlier',1,true),'Unsorted scope not rendered')
vim.cmd('vsplit'); local w2=api.nvim_get_current_win(); api.nvim_win_set_buf(w2,b2)
update(b2,{symbol('other',5,0,8,0)})
api.nvim_win_set_cursor(w2,{7,1})
assert(shown(w1):find('earlier',1,true) and shown(w2):find('other',1,true),'Split used active window position')
api.nvim_win_set_buf(w2,b1)
assert(shown(w2):find('breadcrumb%-one.txt') and not shown(w2):find('other',1,true),'Stale breadcrumb after buffer switch')
update(b1,{})
assert(not shown(w1):find('earlier',1,true),'Empty symbols did not clear old scope')
update(b1,{symbol('earlier',0,0,3,0)})
api.nvim_buf_set_lines(b1,0,0,false,{'inserted'})
assert(not shown(w1):find('earlier',1,true),'Stale scope shown while symbols refresh')
update(b1,{symbol('updated',1,0,4,0)})
assert(shown(w1):find('updated',1,true),'Fresh symbols did not redraw')
print('PASS: per-window rendering, unsorted scopes, buffer switching without movement, clearing empty/stale scopes, fresh symbol updates')
