syntax region vimSet matchgroup=vimCommand start="\<Set\>" skip="\%(\\\\\)*\\." end="$" end="|" matchgroup=vimNotation end="<[cC][rR]>" keepend oneline contains=vimSetEqual,vimOption,vimErrSetting,vimComment,vim9Comment,vimSetString,vimSetMod

" Highlight expr in string interpolation
syntax region vimString start=+$'+ end=+'+ oneline contains=vimStringInterpolationBrace,vimStringInterpolationExpr
syntax region vimString start=+$"+ end=+"+ oneline contains=@vimStringGroup,vimStringInterpolationBrace,vimStringInterpolationExpr
syntax region vimStringInterpolationExpr start=+{+ end="}" keepend oneline contains=vimFuncVar,vimIsCommand,vimOper,vimNotation,vimOperParen,vimString,vimVar
syntax match vimStringInterpolationBrace "{{"
syntax match vimStringInterpolationBrace "}}"
highlight default link vimStringInterpolationBrace vimEscape
