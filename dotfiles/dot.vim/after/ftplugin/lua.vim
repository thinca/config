SetUndoFtplugin setl include< includeexpr< suffixesadd<

setlocal include=^\s*require
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal suffixesadd=.lua
