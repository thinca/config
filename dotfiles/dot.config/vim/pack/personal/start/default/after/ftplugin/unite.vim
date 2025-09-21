nmap <buffer> <nowait> q <Plug>(unite_all_exit)
imap <buffer> <C-q> <Plug>(unite_all_exit)

nmap <buffer> s <Plug>(unite_toggle_mark_current_candidate)

imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

nnoremap <buffer> <expr> <C-j> unite#do_action('below')
nnoremap <buffer> <expr> <C-k> unite#do_action('right')
nnoremap <buffer> <expr> <C-l> unite#do_action('tabopen')
nnoremap <buffer> <expr> T unite#do_action('tabvsplit')

inoremap <buffer> <expr> <C-j> unite#do_action('below')
inoremap <buffer> <expr> <C-k> unite#do_action('right')
inoremap <buffer> <expr> <C-l> unite#do_action('tabopen')

nmap <buffer> <C-z> <Plug>(unite_redraw)
inoremap <buffer> <Plug>(C-o) <C-o>
imap <buffer> <C-z> <Plug>(C-o)<C-z>

let s:context = unite#get_context()

if s:context.buffer_name =~# '^file'
  if executable('ag')
    inoremap <buffer> <expr> <C-e> unite#do_action('rec/async')
  else
    inoremap <buffer> <expr> <C-e> unite#do_action('rec')
  endif
  inoremap <buffer> <expr> <C-f> unite#do_action('narrow')
  inoremap <buffer> <expr> <C-g> unite#do_action('grep_directory')
endif

if s:context.buffer_name ==# 'completion'
  inoremap <buffer> <expr> <C-y> unite#do_action('insert')
endif

if s:context.buffer_name ==# 'outline'
  nnoremap <buffer> <expr> p unite#do_action('persist_open')
endif

let b:cursorline_disable = 1
