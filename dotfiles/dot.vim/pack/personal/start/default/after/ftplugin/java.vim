SetUndoFtplugin setlocal ofu< cfu< efm< mp<
SetUndoFtplugin autocmd! custom-ftplugin-java * <buffer>

setlocal include=^import

" Avoid jsp.
if &l:filetype == 'java'
  compiler javac
endif

function s:makeOption()
  let opt = ' '
  if exists('b:classpath')
    let opt .= '-classpath ' . b:classpath . ' '
  elseif exists('g:classpath')
    let opt .= '-classpath ' . g:classpath . ' '
  endif
  let fenc = &fenc == '' ? &enc : &fenc
  let opt .= '-encoding ' . fenc . ' '
  return opt
endfunction

function s:quickfixEncode()
  if &termencoding == '' || &termencoding ==# &encoding
    return
  endif
  let list = getloclist(0)
  if empty(list)
    return
  endif
  for d in list
    let d.text = iconv(d.text, &termencoding, &encoding)
  endfor
  call setloclist(0, list)
endfunction

augroup custom-ftplugin-java
  autocmd! * <buffer>
  " autocmd BufWritePost <buffer> execute 'silent! lmake!' . s:makeOption() . '"%"'
  autocmd QuickFixCmdPost <buffer> call s:quickfixEncode()
augroup END

" setlocal omnifunc=javacomplete#Complete

" Search "package", and :lcd.
function s:cd_to_package()
  for i in range(1, line('$'))
    let line = getline(i)
    if line =~# '^\s*\%(import\|public\|class\)'
      break
    elseif line =~# '\v^\s*package\s+[[:alnum:].]+\s*;\s*$'
      let b:lcd = expand('%:p:h') . '/' .
      \           repeat('../', strlen(substitute(line, '[^.]', '', 'g')) + 1)
      lcd `=b:lcd`
      let b:lcd = getcwd()  " Normalize
      return
    endif
  endfor
endfunction
if filereadable(bufname('')) " File exists on local?
  call s:cd_to_package()
endif
