syntax match rstNumberedList /^\s*\zs\%(\a\+\.\|\d\+\.\|(\?\d\+)\) /
syntax match rstUnnumberedList /^\s*[-+*] /

highlight default link rstNumberedList Identifier
highlight default link rstUnnumberedList Identifier
