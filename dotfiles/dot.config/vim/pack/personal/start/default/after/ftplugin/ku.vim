imap <buffer> <C-c> <Plug>(ku-cancel)
imap <buffer> <C-[> <Plug>(ku-cancel)
imap <buffer> <ESC> <Plug>(ku-cancel)
imap <buffer> <CR> <Plug>(ku-do-the-default-action)
imap <buffer> <Tab> <Plug>(ku-choose-an-action)
imap <buffer> <C-l> <Plug>(ku-choose-source)

inoremap <buffer> <C-j> <ESC>:KuDoAction below<CR>
inoremap <buffer> <C-k> <ESC>:KuDoAction right<CR>
inoremap <buffer> <C-l> <ESC>:KuDoAction tab-right<CR>

setlocal nonumber
NeoComplCacheLock

" It is necessary to avoid the setting of the default key mapping.
let b:did_ftplugin = 1
