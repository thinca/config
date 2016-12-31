
syntax sync fromstart

syn match jsonString /"\%(true\|false\|null\)\?"/ contains=jsonQuote
syn match jsonNumber /"-\=\<\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\>"/ contains=jsonQuote
syn match jsonQuote /"/ contained

highlight link jsonBraceNotClosedError Error
