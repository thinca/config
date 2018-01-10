SetUndoFtplugin nunmap <buffer> mt
SetUndoFtplugin iunmap <buffer> @

nnoremap <buffer> <silent> mt :<C-u>echo tsuquyomi#hint()<CR>

function! s:at()
  return CurrentSyntax() =~# 'String\|Comment\|None' ? '@' : 'this.'
endfunction
inoremap <expr> <buffer> @ <SID>at()
