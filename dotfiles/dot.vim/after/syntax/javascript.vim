if b:current_syntax !=# 'javascript'
  finish
endif
unlet b:current_syntax
syntax include @javaScriptE4X syntax/xml.vim
let b:current_syntax = 'javascript'

syntax region javaScriptE4XEmbedded matchgroup=javaScriptBraces start='{' end='}' contains=TOP,javaScriptE4X contained

" syntax cluster xmlStartTagHook  add=javaScriptE4XEmbedded
" syntax cluster xmlRegionHook    add=javaScriptE4XEmbedded
" syntax cluster xmlTagHook       add=javaScriptE4XEmbedded

syntax region javaScriptE4X
\ matchgroup=xmlTag
\ start='<\z(\w*\)\%(\_s*\w\+\_s*=\_s*".\{-}"\)*\_s*>'
\ skip='<!--\_.\{-}-->'
\ matchgroup=xmlEndTag
\ end='</\z1\_s*>'
\ contains=@javaScriptE4X,javaScriptE4XEmbedded
\ extend
\ containedin=ALLBUT,javaScriptComment,javaScriptLineComment,javaScriptDocComment,javaScriptStringD,javaScriptStringS,javaScriptRegexpString,javaScriptE4X

" \ contains=@javaScriptE4X
