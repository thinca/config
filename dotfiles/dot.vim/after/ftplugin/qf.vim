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

function! s:jk(motion)
  let max = line('$')
  let list = getloclist(0)
  if empty(list) || len(list) != max
    let list = getqflist()
  endif
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

if exists('*s:undo_entry')
  finish
endif

function! s:undo_entry()
  let history = get(w:, 'qf_history', [])
  if !empty(history)
    call setqflist(remove(history, -1), 'r')
  endif
endfunction

function! s:del_entry() range
  let qf = getqflist()
  let history = get(w:, 'qf_history', [])
  call add(history, copy(qf))
  let w:qf_history = history
  unlet! qf[a:firstline - 1 : a:lastline - 1]
  call setqflist(qf, 'r')
  execute a:firstline
endfunction
