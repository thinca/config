syntax match vimWrongFunctionCall /^\s*\zs[[:alnum:]#:_]\+\ze(/ containedin=vimFuncBody
highlight link vimWrongFunctionCall Error
