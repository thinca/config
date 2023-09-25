let s:prev_file_pat = '.'
function vimrc#grep(...) abort
  if 2 <= a:0
    let files = a:1
    let pat = join(a:000[1 :], ' ')
  elseif a:0 == 1
    let files = s:prev_file_pat
    let pat = a:1
  else
    return
  endif
  if &grepprg ==# 'internal'
    execute 'vimgrep' '/' .. escape(pat, '/') .. '/j' files
  else
    execute 'grep!' '"' .. escape(pat, ' %#') .. '"' files
  endif
endfunction

function vimrc#move(file, bang, base) abort
  let pwd = getcwd()
  cd `=a:base`
  try
    let from = expand('%:p')
    let to = simplify(expand(a:file))
    let bang = a:bang
    if isdirectory(to)
      let to ..= '/' .. fnamemodify(from, ':t')
    endif
    if filereadable(to) && !bang
      echo '"' .. to .. '" is exists. Overwrite? [yN]'
      if nr2char(getchar()) !=? 'y'
        echo 'Cancelled.'
        return
      endif
      let bang = '!'
    endif
    let dir = fnamemodify(to, ':h')
    call mkdir(dir, 'p')
    execute 'saveas' .. bang '`=to`'
    call delete(from)
  finally
    cd `=pwd`
  endtry
endfunction

function vimrc#delete_with_confirm(file, force) abort
  let file = a:file ==# '' ? expand('%') : a:file
  if !a:force
    echo 'Delete "' .. file .. '"? [y/N]:'
  endif
  if a:force || nr2char(getchar()) ==? 'y'
    call delete(file)
    echo 'Deleted "' .. file .. '"!'
  else
    echo 'Cancelled.'
  endif
endfunction

function vimrc#unique_lines(pat) range abort
  let lines = g:V.uniq_by(
  \   getline(a:firstline, a:lastline),
  \   { val -> a:pat ==# '' ? val : matchstr(val, a:pat) }
  \ )
  silent execute a:firstline .. ',' .. a:lastline .. 'delete _'
  silent execute (a:firstline - 1) .. 'put =lines'
endfunction

function vimrc#ctags(args) abort
  let args = a:args
  let dir = '.'
  if !empty(args) && isdirectory(args[0])
    let dir = args[0]
    call remove(args, 0)
  endif

  if !empty(args) && args[0] !~# '^-'
    echoerr 'Invalid options: ' .. join(args)
    return
  endif

  let tagfile = s:tagfile()
  if tagfile !=# ''
    let dir = fnamemodify(tagfile, ':h')
    let args += ['-f', tagfile]
  endif

  if has('win32')
    let enc = get({
    \   'utf-8': 'utf8',
    \   'cp932': 'sjis',
    \   'euc-jp': 'euc',
    \ }, &l:fileencoding ==# '' ? &encoding : &l:fileencoding, '')
    if enc !=# ''
      let args += ['--jcode=' .. enc]
    endif
  endif
  let lang = get({
  \   'cpp': 'C++',
  \   'c': 'C++',
  \   'java': 'Java',
  \ }, &l:filetype, '')
  if lang !=# ''
    let args += ['--languages=' .. lang]
  endif

  call map(add(args, dir), 'shellescape(v:val)')

  let cmd = printf('ctags -R --tag-relative=yes %s', join(args))
  if has('win32')
    let cmd = 'start /b ' .. cmd
  else
    let cmd ..= ' &'
  endif
  silent execute '!' .. cmd
endfunction

function s:tagfile() abort
  let files = tagfiles()
  return empty(files) ? '' : files[0]
endfunction

function vimrc#highlight_with(args) range abort
  if a:firstline == 1 && a:lastline == line('$')
    return
  endif
  let c = get(b:, 'highlight_count', 0)
  let ft = matchstr(a:args, '^\w\+')
  if globpath(&runtimepath, 'syntax/' .. ft .. '.vim') ==# ''
    return
  endif
  if exists('b:current_syntax')
    let syntax = b:current_syntax
    unlet b:current_syntax
  endif
  let save_isk = &l:isk  " for scheme.
  let hlname = 'highlightWith' .. substitute(ft, '^.', '\u\0', '')
  if c != 0
    let hlname ..= '_' .. c
  endif
  execute printf('syntax include @%s syntax/%s.vim', hlname, ft)
  let &l:isk = save_isk
  execute printf('syntax region %s start=/\%%%dl/ end=/\%%%dl$/ '
  \            .. 'contains=@%s containedin=ALL',
  \             hlname, a:firstline, a:lastline, hlname)
  let b:highlight_count = c + 1
  if exists('syntax')
    let b:current_syntax = syntax
  endif
endfunction

function vimrc#keep_cursor(cmd) abort
  let curwin_id = win_getid()
  let view = winsaveview()
  try
    execute a:cmd
  finally
    if win_getid() == curwin_id
      call winrestview(view)
    endif
  endtry
endfunction

function vimrc#opener(cmdline, ...) abort
  if a:0
    let file = a:1
  else
    let arg = matchstr(a:cmdline, '\%(\\.\|\S\)\+$')
    if arg =~# '^`.*`$'
      let arg = system(file[1 : -2])
    endif
    let file = resolve(fnamemodify(glob(arg), ':p'))
  endif
  let opened = s:bufopened(file)
  let opt = a:cmdline[: -len(arg) - 1]
  if !empty(opened)
    execute 'tabnext' opened[0]
    execute opened[1] 'wincmd w'
    if opt =~# '\S'
      silent execute 'edit' opt
    endif
  else
    return 'tabnew ' .. a:cmdline
  endif
  return ''
endfunction

function s:bufopened(file) abort
  let f = fnamemodify(a:file, ':p')
  for tabnr in range(1, tabpagenr('$'))
    let winnr = 1
    for nbuf in tabpagebuflist(tabnr)
      if f ==# fnamemodify(bufname(nbuf), ':p')
        return [tabnr, winnr]
      endif
      let winnr += 1
    endfor
  endfor
  return []
endfunction

function vimrc#check_interface() abort
  try
    let lua_ver = substitute(luaeval('_VERSION'), '^Lua ', 'v', '')
  catch
    let lua_ver = 'no'
  endtry
  echo 'Lua ... ' .. lua_ver

  try
    let perl_ver = perleval('"$^V"')
  catch
    let perl_ver = 'no'
  endtry
  echo 'Perl ... ' .. perl_ver

  try
    python import platform
    let python_ver = 'v' .. pyeval('platform.python_version()')
  catch
    let python_ver = 'no'
  endtry
  echo 'Python 2 ... ' .. python_ver

  try
    python3 import platform
    let python3_ver = 'v' .. py3eval('platform.python_version()')
  catch
    let python3_ver = 'no'
  endtry
  echo 'Python 3 ... ' .. python3_ver

  try
    ruby Vim::command("let ruby_ver = 'v#{RUBY_VERSION}'")
  catch
    let ruby_ver = 'no'
  endtry
  echo 'Ruby ... ' .. ruby_ver

  try
    tcl ::vim::command "let tcl_ver = 'v[info patchlevel]'"
  catch
    let tcl_ver = 'no'
  endtry
  echo 'Tcl ... ' .. tcl_ver

  try
    let mzscheme_ver = 'v' .. mzeval('(version)')
  catch
    let mzscheme_ver = 'no'
  endtry
  echo 'MzScheme ... ' .. mzscheme_ver
endfunction

function vimrc#time(cmd, log) abort
  if !has('reltime')
    echo 'Feature +reltime is disabled.' .
    \    '  Do you run the command in normally?[y/N]'
    if getchar() =~? 'y'
      execute a:cmd
    endif
    return
  endif

  let time = reltime()
  let mes = execute(a:cmd)
  let result = a:cmd .. ': ' .. reltimestr(reltime(time))

  echo mes

  if a:log
    echomsg result
  else
    echo result
  endif
endfunction

def vimrc#profile(cmd: string): void
  const dir = expand('~/.local/log/vim/')
  mkdir(dir, 'p')
  const filename = dir ..  strftime('profile_%Y-%m-%d_%H-%M-%S.log')
  execute $'profile start {filename}'
  profile! file *
  profile func *
  execute cmd
  profile stop
  new `=filename`
enddef

def vimrc#modulo(m: number, n: number): number
  const d = m * n < 0 ? 1 : 0
  return m + (-(m + (0 < n ? d : -d)) / n + d) * n
enddef
