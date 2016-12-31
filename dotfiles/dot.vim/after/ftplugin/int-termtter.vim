match Error /\c\<thinca\>/
2match Todo /\cvim/

augroup custom-int-termtter
  autocmd!
  autocmd CursorMovedI,InsertLeave <buffer> let b:statusline_extra = s:count()
augroup END

let s:pat =  '^>\s\+u\%(pdate\)\?\>\s*\zs.*$'
function! s:count()
  let l = getline('$')
  if l !~# s:pat
    return ''
  endif
  let num = len(substitute(matchstr(l, s:pat), '.', 'x', 'g'))
  return '[' . (140 - num) . ']'
endfunction
