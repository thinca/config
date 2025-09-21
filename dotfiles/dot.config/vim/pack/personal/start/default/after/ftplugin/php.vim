SetUndoFtplugin unlet! b:ftdetect
SetUndoFtplugin setl et< sw< sts< path<
SetUndoFtplugin iunmap <buffer> @

setlocal expandtab shiftwidth=4 softtabstop=4

if executable('php')
  if !exists('s:path')
    let s:path = substitute(system('php', '<?php print get_include_path() ?>'),
    \                        '[:;]', ',', 'g')
  endif
  let &l:path = s:path
endif

function s:at()
  return CurrentSyntax() =~# 'String\|Comment\|None' ? '@' : '$this->'
endfunction
inoremap <expr> <buffer> @ <SID>at()

compiler php
