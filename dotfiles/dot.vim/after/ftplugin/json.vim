setlocal foldtext=JsonFoldText()

function! JsonFoldText()
  return foldtext()
  let base = matchstr(foldtext(), '^.\{-}:')
  let lines = getline(v:foldstart, v:foldend)
endfunction
