:keeppatterns % s/COMPILER_NAME/\=expand('%:t:r')/ge
" Vim compiler file
" Language: COMPILER_NAME
" Version:  1.0
" Author:   thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('current_compiler')
  finish
endif
let current_compiler = 'COMPILER_NAME'

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif


