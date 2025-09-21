if executable('jad')
  silent %!jad -t -clear -ff -nonlb -8 -p "%"
  runtime! syntax/java.vim
  setlocal readonly

  SetUndoFtplugin setl ro<
  SetUndoFtplugin silent undo
endif
