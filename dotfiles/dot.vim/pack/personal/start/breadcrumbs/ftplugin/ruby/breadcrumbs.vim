if expand('%') =~# '_spec\.rb$'
  let b:breadcrumbs_converter = function('s:convert')

  if exists('*s:convert')
    finish
  endif

  function s:convert(item) abort
    let item = matchstr(a:item, '\%(RSpec\.\)\?\%(describe\|context\|it\)\s\+\zs.\{-}\ze\s\+do$')
    let item = substitute(item, '^\%(\([''"]\)\(.*\)\1\|\(\w\+\)\).*', '\2\3', '')
    return item
  endfunction
endif
