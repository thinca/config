if exists(':Setlocal') == 2
  Setlocal whichwrap=b,s,<,>,[,],h,l
endif
nunmap <buffer> <Left>
nunmap <buffer> <Right>
nmap <buffer> < <Plug>CalendarGotoPrevMonth
nmap <buffer> > <Plug>CalendarGotoNextMonth
