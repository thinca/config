:% s@PLUGIN@\=expand('%:p:r:s?.*[/\\]plugin[/\\]??:gs?[/\\]?_?')@ge
if exists('g:loaded_PLUGIN')
  finish
endif
let g:loaded_PLUGIN = 1


