SetUndoFtplugin mapclear <buffer>
SetUndoFtplugin setlocal stl&

noremap <buffer> <CR> <CR>
noremap <silent> <buffer> <expr> j <SID>jk(v:count1)
noremap <silent> <buffer> <expr> k <SID>jk(-v:count1)
noremap <buffer> gj gj
noremap <buffer> gk gk

noremap <buffer> p  <CR>zz<C-w>p
noremap <buffer> J j<CR>zz<C-w>p
noremap <buffer> K k<CR>zz<C-w>p
noremap <buffer> <nowait> q <C-w>c

nnoremap <silent> <buffer> r :<C-u>Qfreplace<CR>
nnoremap <silent> <buffer> u :<C-u>Unite qf<CR>

function s:jk(motion)
  let max = line('$')
  let list = s:getlist()
  let cur = line('.') - 1
  let pos = g:V.modulo(cur + a:motion, max)
  let m = 0 < a:motion ? 1 : -1
  while cur != pos && list[pos].bufnr == 0
    let pos = g:V.modulo(pos + m, max)
  endwhile
  return (pos + 1) . 'G'
endfunction

" if exists(':Setlocal') == 2
  " Setlocal nosplitbelow
" endif
setlocal statusline+=\ %L

nnoremap <silent> <buffer> dd :call <SID>del_entry()<CR>
nnoremap <silent> <buffer> x :call <SID>del_entry()<CR>
vnoremap <silent> <buffer> d :call <SID>del_entry()<CR>
vnoremap <silent> <buffer> x :call <SID>del_entry()<CR>
nnoremap <silent> <buffer> u :<C-u>call <SID>undo_entry()<CR>

command! -nargs=* -bang -buffer QfGrep call s:grep(<q-args>, <bang>0)

if exists('*s:undo_entry')
  finish
endif

function s:grep(pat, invert) abort
  let pat = a:pat =~# '\S' ? a:pat : @/
  let qf = s:getlist()
  call s:add_history(qf)
  let op = a:invert ? '!~#' : '=~#'
  call filter(qf, 'v:val.text ' . op . ' pat')
  call s:setlist(qf)
endfunction

function s:is_loclistwin() abort
  return win_getid() == getloclist(0, {'winid': 1}).winid
endfunction

function s:getlist() abort
  if s:is_loclistwin()
    return getloclist(0)
  else
    return getqflist()
  endif
endfunction

function s:setlist(list) abort
  if s:is_loclistwin()
    call setloclist(0, a:list, 'r')
  else
    call setqflist(a:list, 'r')
  endif
endfunction

function s:undo_entry()
  let history = get(w:, 'qf_history', [])
  if !empty(history)
    call s:setlist(remove(history, -1))
  endif
endfunction

function s:del_entry() range
  let qf = s:getlist()
  call s:add_history(qf)
  unlet! qf[a:firstline - 1 : a:lastline - 1]
  call s:setlist(qf)
  execute a:firstline
endfunction

function s:add_history(qf) abort
  let history = get(w:, 'qf_history', [])
  call add(history, copy(a:qf))
  let w:qf_history = history
endfunction
