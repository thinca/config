SetUndoFtplugin iunmap <buffer> @

function s:at()
  if CurrentSyntax() =~# 'String\|Comment\|None'
    return '@'
  endif
  return smartchr#loop('@', 'this.')
endfunction
inoremap <expr> <buffer> @ <SID>at()
