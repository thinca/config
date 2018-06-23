finish
let b:ftdetect = 1

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfunction

if !exists('s:config')
  let s:config = {
  \   'exec': [':echo ' . s:SID() . "execute_scala('%S:p', self)"],
  \   'tempfile': '{' . s:SID() . 'class(self)}.scala',
  \   'delete': 1,
  \ }

  function! s:config.getfiles(f)
    return [a:f]
  endfunction

  function! s:config.dir()
    return tempname()
  endfunction

  let s:config.options = ['-unchecked', '-deprecation']
endif

if search('^\s*\%(class\|object\)\>', 'wn')
  if !exists('b:quickrun_config')
    let b:quickrun_config = {}
  endif
  let b:quickrun_config = extend(copy(s:config), b:quickrun_config)
endif

let s:rmdir = split(has('win32') || has('win64') ? 'rmdir /S /Q' : 'rmdir -fr')

function! s:class(self)
  let src = a:self.config.src
  return type(src) == type(0) ? fnamemodify(bufname(src), ':t:r')
  \                           : matchstr(src, '\(^\|\n\)\s*\<object\>\s\+\zs\w\+')
endfunction


function! s:execute_scala(file, self)
  let class = s:class(a:self)
  let dir = a:self.config.dir()
  if !isdirectory(dir)
    call mkdir(dir)
  endif
  let files = a:self.config.getfiles(a:file)
  try
    let compile_error = vimproc#system(['fsc', '-d', dir] + a:self.config.options + files)
    if compile_error != ''
      return compile_error
    endif
    let res = vimproc#system(['scala', '-classpath', dir, class])
    return iconv(res, &termencoding, &encoding)
  finally
    if a:self.config.delete
      call vimproc#system(s:rmdir + [dir])
    endif
  endtry
endfunction
