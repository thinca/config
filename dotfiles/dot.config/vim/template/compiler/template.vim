:keeppatterns % s/COMPILER_NAME/\=expand('%:t:r')/ge
if exists('g:current_compiler')
  finish
endif
let g:current_compiler = 'COMPILER_NAME'

if exists(':CompilerSet') != 2  " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif
