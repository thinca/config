function vimrc#ddu#file_external_cmd(path) abort
  let path = fnamemodify(a:path, ':p')
  if finddir('.git', path .. ';') isnot# '' ||
  \   findfile('.git', path .. ';') isnot# ''
    return ['git', 'ls-files', '--cached', '--others', '--exclude-standard']
  endif
  if executable('fd')
    return [
    \   'fd',
    \   '--hidden',
    \   '--type', 'file',
    \   '--type', 'symlink',
    \   '--exclude', '.git',
    \   '--color', 'never',
    \ ]
  endif
  if executable('find')
    return ['find']
  endif
  return []
endfunction

function vimrc#ddu#setup_ui_ff_buffer() abort
  let b:cursorline_disable = v:true
  nnoremap <buffer> <CR>
  \ <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer> <nowait> s
  \ <Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>
  nnoremap <buffer> i
  \ <Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>
  nnoremap <buffer> q
  \ <Cmd>call ddu#ui#ff#do_action('quit')<CR>

  if b:ddu_ui_name is# 'file_rec'
    call s:ddu_setup_keymappings_for_file()
  endif
endfunction

function vimrc#ddu#setup_ui_ff_filter_buffer() abort
  inoremap <buffer> <C-c> <Esc><Cmd>call ddu#ui#ff#close()<CR>
  nnoremap <buffer> q <Cmd>call ddu#ui#ff#close()<CR>
  inoremap <buffer> <CR> <Esc><Cmd>call ddu#ui#ff#do_action('itemAction')<CR>
  nnoremap <buffer> <CR> <Cmd>call ddu#ui#ff#do_action('itemAction')<CR>

  inoremap <buffer> <expr> <C-h> getline('.') is# '' ? '<Esc><Cmd>close<CR>' : '<C-h>'

  inoremap <buffer> <C-n> <Cmd>call ddu#ui#ff#execute('call cursor(line(".") + 1, 0)')<CR>
  inoremap <buffer> <C-p> <Cmd>call ddu#ui#ff#execute('call cursor(line(".") - 1, 0)')<CR>
  nnoremap <buffer> <C-n> <Cmd>call ddu#ui#ff#execute('call cursor(line(".") + 1, 0)')<CR>
  nnoremap <buffer> <C-p> <Cmd>call ddu#ui#ff#execute('call cursor(line(".") - 1, 0)')<CR>

  if b:ddu_ui_name is# 'file_rec'
    call s:ddu_setup_keymappings_for_file()
  endif
endfunction

function s:ddu_setup_keymappings_for_file() abort
  nnoremap <buffer> <C-j>
  \ <Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright split'}}
  \ )<CR>
  nnoremap <buffer> <C-k>
  \ <Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright vsplit'}}
  \ )<CR>
  nnoremap <buffer> <C-l>
  \ <Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'tabnew'}}
  \ )<CR>

  inoremap <buffer> <C-j>
  \ <Esc><Cmd>close<CR><Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright split'}}
  \ )<CR>
  inoremap <buffer> <C-k>
  \ <Esc><Cmd>close<CR><Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'botright vsplit'}}
  \ )<CR>
  inoremap <buffer> <C-l>
  \ <Esc><Cmd>close<CR><Cmd>call ddu#ui#ff#do_action(
  \   'itemAction',
  \   #{name: 'open', params: #{command: 'tabnew'}}
  \ )<CR>
endfunction
