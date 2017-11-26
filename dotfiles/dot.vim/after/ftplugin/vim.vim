SetUndoFtplugin setl ts< sw< sts< sta< et< ai< kp< tw< fo< ml< cc<

setlocal tabstop=2 shiftwidth=2 softtabstop=2 smarttab expandtab
setlocal autoindent keywordprg=:help
setlocal textwidth=78 formatoptions-=r formatoptions-=o
setlocal colorcolumn=+1
if &modifiable
  setlocal fileformat=unix
endif
if expand('%:e') ==? 'vim'
  setlocal nomodeline
  SetUndoFtplugin setl ml<
endif
" setlocal foldmethod<
