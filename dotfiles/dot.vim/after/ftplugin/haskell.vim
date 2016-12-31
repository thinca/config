SetUndoFtplugin setl ts< sw< sts< sta< et< ai< inc< inex< sua<
SetUndoFtplugin autocmd! custom-ftplugin-haskell * <buffer>

setlocal tabstop=8 shiftwidth=2 softtabstop=2 smarttab expandtab autoindent
setlocal include=^import
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal suffixesadd=.hs

" compiler ghc

augroup custom-ftplugin-haskell
  autocmd! * <buffer>
  autocmd BufWritePost <buffer> silent! lmake! -c "%"
augroup END
