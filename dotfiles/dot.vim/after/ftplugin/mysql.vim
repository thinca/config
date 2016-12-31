function! s:define_abbr(list)
  for word in a:list
    execute printf('inoreabbrev <buffer> %s %s', word, toupper(word))
  endfor
endfunction

function! s:get_keywords(syn)
  return filter(split(matchstr(Redir('syntax list ' . a:syn),
  \             'xxx \zs\_.*\ze links to')), 'v:val !~# "\\W"')
endfunction

if !exists('s:keywords')
  let s:keywords = s:get_keywords('mysqlKeyword')
  \              + s:get_keywords('mysqlOperator')
  \              + s:get_keywords('mysqlSpecial')
endif

if empty(s:keywords)
  let s:sfile = expand('<sfile>')
  augroup custom-ftplugin-mysql
    autocmd!
    autocmd Syntax mysql source `=s:sfile`
  augroup END
else
  call s:define_abbr(s:keywords)
endif
