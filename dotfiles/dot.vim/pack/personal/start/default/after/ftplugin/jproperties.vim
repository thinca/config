SetUndoFtplugin setl isk<

setlocal iskeyword+=.

if executable("native2ascii") && &modifiable
  function! s:is_ascii_only()
    return !search('[^\x00-\x7F]', 'cnw')
  endfunction

  function! s:encode()
    if s:is_ascii_only()
      return
    endif
    call s:with_cursor('silent %!native2ascii -encoding ' . s:java_encoding())
  endfunction
  function! s:decode()
    if s:is_ascii_only()
      return
    endif
    call s:with_cursor('silent %!native2ascii -reverse -encoding ' . s:java_encoding())
  endfunction

  function! s:java_encoding()
    let enc = &fileencoding ==# '' ? &encoding : &fileencoding
    return get({
    \ 'cp932': 'Shift_JIS',
    \ }, enc, enc)
  endfunction

  function! s:with_cursor(cmd)
    let cursor = getpos('.')
    execute a:cmd
    call setpos('.', cursor)
  endfunction
  SetUndoFtplugin au! custom-ftplugin-jproperties * <buffer>
  SetUndoFtplugin do BufWritePre <buffer>
  call s:decode()

  augroup custom-ftplugin-jproperties
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call s:encode()
    autocmd BufWritePost <buffer> call s:decode()
  augroup END
endif
