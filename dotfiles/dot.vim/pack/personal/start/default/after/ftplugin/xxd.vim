if !executable('xxd')
  finish
endif
SetUndoFtplugin setl bin< eol<
SetUndoFtplugin au! custom-ftplugin-xxd * <buffer>
SetUndoFtplugin call XxdRestore()

function! s:to_xxd()
  silent %!xxd -g 1
  silent! %substitute/\r$//e
  let b:xxd = 1
endfunction

" FIXME
function! XxdRestore()
  call s:restore()
endfunction
function! s:restore()
  if exists('b:xxd')
    silent %!xxd -r
    unlet! b:xxd
  endif
endfunction

function! s:write_pre()
  let b:xxd_cursor = getpos('.')
  call s:restore()
endfunction

function! s:write_post()
  call s:to_xxd()
  setlocal nomodified
  if exists('b:xxd_cursor')
    call setpos('.', b:xxd_cursor)
    unlet b:xxd_cursor
  endif
endfunction


let s:bin = &l:binary
setlocal binary noendofline
if !s:bin && !&l:modified
  noautocmd edit  " reload with binary mode.
endif
unlet s:bin

call s:to_xxd()
augroup custom-ftplugin-xxd
  autocmd! * <buffer>
  autocmd BufReadPre <buffer> unlet! b:xxd
  autocmd BufReadPost <buffer> call s:to_xxd()
  autocmd BufWritePre <buffer> call s:write_pre()
  autocmd BufWritePost <buffer> call s:write_post()

  autocmd CursorMovedI <buffer> call s:complete()
augroup END


function! s:complete()
  if getline('.') != ''
    return
  endif
  let addr = line('.') == 1
  \ ? 0 : str2nr(matchstr(getline(line('.') - 1), '^\x*'), 16) + 16

  call setline('.', printf('%07x: ', addr))
  startinsert!
endfunction
