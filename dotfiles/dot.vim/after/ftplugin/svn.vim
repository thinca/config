SetUndoFtplugin setl ml< fenc<

setlocal nomodeline

if &termencoding != ''
  let &l:fileencoding = &termencoding
endif
