SetUndoFtplugin setl path<
SetUndoFtplugin autocmd! custom-ftplugin-perl * <buffer>

let g:perl_compiler_force_warnings = 0

compiler perl

if executable('perl')
  if !exists('s:path')
    let s:path = system('perl -e ' .
    \   shellescape('print join(q/,/, map{$_=~s/([, ])/\\$1/g;$_}@INC)'))
  endif
  let &l:path = s:path
endif

augroup custom-ftplugin-perl
  autocmd! * <buffer>
  autocmd BufWritePost <buffer> silent! lmake! "%"
augroup END
