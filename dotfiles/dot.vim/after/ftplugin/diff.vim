SetUndoFtplugin setl inex<

let &l:includeexpr = 'filereadable(v:fname) || isdirectory(v:fname) ? v:fname : substitute(v:fname, "^[ab]/", "", "")'
