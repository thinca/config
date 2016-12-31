" Vim color file -- candycode
" Maintainer:   Justin Constantino <goflyapig-at-gmail-com>
" Last Change:  2006 Aug 12

highlight clear
let g:colors_name="candycode"

let s:save_cpo = &cpo
set cpo&vim

" basic highlight groups (:help highlight-groups) {{{

" text {{{

hi Normal guifg=#ffffff guibg=#050505 gui=NONE ctermbg=16 ctermfg=231 cterm=NONE

hi Folded guifg=#c2bfa5 guibg=#050505 gui=underline ctermbg=16 ctermfg=145 cterm=underline

hi LineNr guifg=#928c75 guibg=NONE gui=NONE ctermbg=NONE ctermfg=102 cterm=NONE

hi Directory guifg=#00bbdd guibg=NONE gui=NONE ctermbg=NONE ctermfg=38 cterm=NONE
hi NonText guifg=#77ff22 guibg=NONE gui=bold ctermbg=NONE ctermfg=118 cterm=bold
hi SpecialKey guifg=#559933 guibg=NONE gui=NONE ctermbg=NONE ctermfg=64 cterm=NONE

hi SpellBad guifg=NONE guibg=NONE gui=undercurl guisp=#ff0011 ctermbg=NONE ctermfg=NONE cterm=undercurl
hi SpellCap guifg=NONE guibg=NONE gui=undercurl guisp=#0044ff ctermbg=NONE ctermfg=NONE cterm=undercurl
hi SpellLocal guifg=NONE guibg=NONE gui=undercurl guisp=#00dd99 ctermbg=NONE ctermfg=NONE cterm=undercurl
hi SpellRare guifg=NONE guibg=NONE gui=undercurl guisp=#ff22ee ctermbg=NONE ctermfg=NONE cterm=undercurl

hi DiffAdd guifg=#ffffff guibg=#126493 gui=NONE ctermbg=24 ctermfg=231 cterm=NONE
hi DiffChange guifg=#000000 guibg=#976398 gui=NONE ctermbg=96 ctermfg=16 cterm=NONE
hi DiffDelete guifg=#000000 guibg=#be1923 gui=bold ctermbg=124 ctermfg=16 cterm=bold
hi DiffText guifg=#ffffff guibg=#976398 gui=bold ctermbg=96 ctermfg=231 cterm=bold

" }}}
" borders / separators / menus {{{

hi FoldColumn guifg=#c8bcb9 guibg=#786d65 gui=bold ctermbg=95 ctermfg=181 cterm=bold
hi SignColumn guifg=#c8bcb9 guibg=#786d65 gui=bold ctermbg=95 ctermfg=181 cterm=bold

hi Pmenu guifg=#000000 guibg=#a6a190 gui=NONE ctermbg=144 ctermfg=16 cterm=NONE
hi PmenuSel guifg=#ffffff guibg=#133293 gui=NONE ctermbg=18 ctermfg=231 cterm=NONE
hi PmenuSbar guifg=NONE guibg=#555555 gui=NONE ctermbg=239 ctermfg=NONE cterm=NONE
hi PmenuThumb guifg=NONE guibg=#cccccc gui=NONE ctermbg=251 ctermfg=NONE cterm=NONE

hi StatusLine guifg=#000000 guibg=#c2bfa5 gui=bold ctermbg=145 ctermfg=16 cterm=bold
hi StatusLineNC guifg=#444444 guibg=#c2bfa5 gui=NONE ctermbg=145 ctermfg=237 cterm=NONE
hi WildMenu guifg=#ffffff guibg=#133293 gui=bold ctermbg=18 ctermfg=231 cterm=bold
hi VertSplit guifg=#c2bfa5 guibg=#c2bfa5 gui=NONE ctermbg=145 ctermfg=145 cterm=NONE

hi TabLine guifg=#000000 guibg=#c2bfa5 gui=NONE ctermbg=145 ctermfg=16 cterm=NONE
hi TabLineFill guifg=#000000 guibg=#c2bfa5 gui=NONE ctermbg=145 ctermfg=16 cterm=NONE
hi TabLineSel guifg=#ffffff guibg=#133293 gui=NONE ctermbg=18 ctermfg=231 cterm=NONE

"hi Menu
"hi Scrollbar
"hi Tooltip

" }}}
" cursor / dynamic / other {{{

hi Cursor guifg=#000000 guibg=#ffff99 gui=NONE ctermbg=228 ctermfg=16 cterm=NONE
hi CursorIM guifg=#000000 guibg=#aaccff gui=NONE ctermbg=153 ctermfg=16 cterm=NONE
hi CursorLine guifg=NONE guibg=#1b1b1b gui=NONE ctermbg=233 ctermfg=NONE cterm=NONE
hi CursorColumn guifg=NONE guibg=#1b1b1b gui=NONE ctermbg=233 ctermfg=NONE cterm=NONE

hi Visual guifg=#ffffff guibg=#606070 gui=NONE ctermbg=59 ctermfg=231 cterm=NONE

hi IncSearch guifg=#000000 guibg=#eedd33 gui=bold ctermbg=220 ctermfg=16 cterm=bold
hi Search guifg=#efefd0 guibg=#937340 gui=NONE ctermbg=100 ctermfg=230 cterm=NONE

hi MatchParen guifg=NONE guibg=#3377aa gui=NONE ctermbg=31 ctermfg=NONE cterm=NONE

"hi VisualNOS

" }}}
" listings / messages {{{

hi ModeMsg guifg=#eecc18 guibg=NONE gui=NONE ctermbg=NONE ctermfg=220 cterm=NONE
hi Title guifg=#dd4452 guibg=NONE gui=bold ctermbg=NONE ctermfg=161 cterm=bold
hi Question guifg=#66d077 guibg=NONE gui=NONE ctermbg=NONE ctermfg=78 cterm=NONE
hi MoreMsg guifg=#39d049 guibg=NONE gui=NONE ctermbg=NONE ctermfg=40 cterm=NONE

hi ErrorMsg guifg=#ffffff guibg=#ff0000 gui=bold ctermbg=196 ctermfg=231 cterm=bold
hi WarningMsg guifg=#ccae22 guibg=NONE gui=bold ctermbg=NONE ctermfg=178 cterm=bold

" }}}

" }}}
" syntax highlighting groups (:help group-name) {{{

hi Comment guifg=#ff9922 guibg=NONE gui=NONE ctermbg=NONE ctermfg=208 cterm=NONE

hi Constant guifg=#ff6050 guibg=NONE gui=NONE ctermbg=NONE ctermfg=203 cterm=NONE
hi Boolean guifg=#ff6050 guibg=NONE gui=bold ctermbg=NONE ctermfg=203 cterm=bold

hi Identifier guifg=#eecc44 guibg=NONE gui=NONE ctermbg=NONE ctermfg=220 cterm=NONE

hi Statement guifg=#66d077 guibg=NONE gui=bold ctermbg=NONE ctermfg=78 cterm=bold

hi PreProc guifg=#bb88dd guibg=NONE gui=NONE ctermbg=NONE ctermfg=140 cterm=NONE

hi Type guifg=#4093cc guibg=NONE gui=bold ctermbg=NONE ctermfg=32 cterm=bold

hi Special guifg=#9999aa guibg=NONE gui=bold ctermbg=NONE ctermfg=103 cterm=bold

hi Underlined guifg=#80a0ff guibg=NONE gui=underline term=underline ctermbg=NONE ctermfg=111 cterm=underline

hi Ignore guifg=#888888 guibg=NONE gui=NONE ctermbg=NONE ctermfg=244 cterm=NONE

hi Error guifg=#ffffff guibg=#ff0000 gui=NONE ctermbg=196 ctermfg=231 cterm=NONE

hi Todo guifg=#ffffff guibg=#ee7700 gui=bold ctermbg=208 ctermfg=231 cterm=bold

" }}}
set background=dark

let &cpo = s:save_cpo

" vim: fdm=marker fdl=0
