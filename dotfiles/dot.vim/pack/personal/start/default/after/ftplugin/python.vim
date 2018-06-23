SetUndoFtplugin setl ts< sw< sts< sta< et< ai< path< fdm<

setlocal tabstop=4 shiftwidth=4 softtabstop=4 smarttab expandtab autoindent
setlocal foldmethod=indent

if executable('python')
  if !exists('s:path')
    let s:path = system('python -',
    \                    'import sys;sys.stdout.write(",".join(sys.path))')
  endif
  let &l:path = s:path
endif
