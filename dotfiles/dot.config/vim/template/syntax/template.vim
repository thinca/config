:keeppatterns % s/LANGUAGE_NAME/\=expand('%:t:r')/ge
if exists('b:current_syntax')
  finish
endif

syntax case match
syntax sync fromstart


" Comments
syntax match LANGUAGE_NAMEComment ""


" highlight
highlight default link LANGUAGE_NAMEComment Comment


let b:current_syntax = 'LANGUAGE_NAME'
