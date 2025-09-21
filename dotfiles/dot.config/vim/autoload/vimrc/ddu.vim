def vimrc#ddu#file_external_cmd(path: string): list<string>
  var full_path = fnamemodify(path, ':p')
  if finddir('.git', full_path .. ';') !=# '' ||
      findfile('.git', full_path .. ';') !=# ''
    return ['git', 'ls-files', '--cached', '--others', '--exclude-standard']
  endif
  if executable('fd')
    return [
      'fd',
      '--hidden',
      '--type', 'file',
      '--type', 'symlink',
      '--exclude', '.git',
      '--color', 'never',
    ]
  endif
  if executable('find')
    return ['find']
  endif
  return []
enddef

def vimrc#ddu#setup_ui_ff_buffer()
  b:cursorline_disable = v:true
  setlocal cursorline
  nnoremap <buffer> <CR>
  \ <Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <buffer> <nowait> s
  \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
  nnoremap <buffer> i
  \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <buffer> q
  \ <Cmd>call ddu#ui#do_action('quit')<CR>

  if b:ddu_ui_name ==# 'file'
    s:setup_keymappings_for_file()
  endif
enddef

def vimrc#ddu#setup_ui_ff_filter_buffer()
  inoremap <buffer> <C-c> <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
  nnoremap <buffer> q <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
  inoremap <buffer> <CR> <Esc><Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <buffer> <CR> <Cmd>call ddu#ui#do_action('itemAction')<CR>

  inoremap <buffer> <expr> <C-h> getline('.') ==# '' ? '<Esc><Cmd>call ddu#ui#do_action("quit")<CR>' : '<C-h>'

  inoremap <buffer> <C-n> <Cmd>call <SID>cursor(+1)<CR>
  inoremap <buffer> <C-p> <Cmd>call <SID>cursor(-1)<CR>
  nnoremap <buffer> <C-n> <Cmd>call <SID>cursor(+1)<CR>
  nnoremap <buffer> <C-p> <Cmd>call <SID>cursor(-1)<CR>

  if b:ddu_ui_name ==# 'file'
    s:setup_keymappings_for_file()
  endif
enddef

def s:cursor(n: number)
  final cmd = $'call cursor(vimrc#modulo(line(".") + {n} - 1, line("$")) + 1, 0)'
  ddu#ui#ff#execute(cmd)
  redraw!
enddef

def s:setup_keymappings_for_file()
  nnoremap <buffer> <C-j>
  \ <Cmd>call ddu#ui#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright split'}}
  \ )<CR>
  nnoremap <buffer> <C-k>
  \ <Cmd>call ddu#ui#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright vsplit'}}
  \ )<CR>
  nnoremap <buffer> <C-l>
  \ <Cmd>call ddu#ui#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'tabnew'}}
  \ )<CR>

  inoremap <buffer> <C-j>
  \ <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR><Cmd>call ddu#ui#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright split'}}
  \ )<CR>
  inoremap <buffer> <C-k>
  \ <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR><Cmd>call ddu#ui#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright vsplit'}}
  \ )<CR>
  inoremap <buffer> <C-l>
  \ <Esc><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR><Cmd>call ddu#ui#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'tabnew'}}
  \ )<CR>
enddef
