SetUndoFtplugin setl et< isk<

if &l:filetype =~? '^\%(x\?html\|eruby\)$'  " It is not PHP, or others.
  setlocal expandtab iskeyword+=-
endif

let b:match_words .= ',{:},(:)'
