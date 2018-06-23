SetUndoFtplugin setlocal et< ts< sw< sts<

setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

vnoremap <buffer> go c<C-r><C-o>=PP(eval(@"))<CR><ESC>
