SetUndoFtplugin autocmd! custom-ftplugin-go * <buffer>
SetUndoFtplugin setlocal et<

compiler go
setlocal noexpandtab

augroup custom-ftplugin-go
  autocmd! * <buffer>
  if executable('gofmt')
    autocmd BufWritePre <buffer> call s:format()
  endif
  autocmd BufWritePost <buffer> silent! lmake! "%"
augroup END

function! s:format()
  let cursor = getpos('.')
  silent! %!gofmt
  if v:shell_error
    let error = join(getline(1, '$'), "\n")
    undo
  endif
  call setpos('.', cursor)
endfunction

