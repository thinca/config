SetUndoFtplugin setl ml<

setlocal nomodeline

silent! unmap <buffer> <C-n>
silent! unmap <buffer> <C-p>
silent! nunmap <buffer> <C-d>

inoremap <silent> <buffer> <SID>(vimshell_hide) <ESC>:hide<CR>
inoremap <silent> <buffer> <SID>(vimshell_complete_history)
\                          <C-r>=<SID>complete_history()<CR><C-p>
" or exit?
imap <buffer> <expr> <C-d>
\    getline('.') =~# '^\V' . g:vimshell_prompt . '\m\s*$' ?
\    "\<SID>(vimshell_hide)" : "\<SID>(vimshell_complete_history)"

" imap <buffer> <C-k> <Plug>(vimshell_history_complete_whole)
imap <buffer> <silent> <C-q> <SID>(vimshell_complete_history)
inoremap <buffer> <expr> <silent>
\        <C-k> unite#sources#vimshell_history#start_complete(1)
nnoremap <buffer> <expr> <silent>
\        <C-k> unite#sources#vimshell_history#start_complete(0)
" imap <buffer> <silent> <C-k> <SID>(vimshell_complete_history)
" inoremap <buffer> <expr> <silent>
" \        <C-q> unite#sources#vimshell_history#start_complete()
imap <buffer> <C-l> <Plug>(vimshell_clear)

function s:complete_history()
  call complete(len(vimshell#get_prompt()) + 1, g:vimshell#hist_buffer)
  return ''
endfunction
