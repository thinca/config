nunmap <buffer> <Space>
vunmap <buffer> <Space>
nmap <buffer> s <Plug>(vimfiler_toggle_mark_current_line)
vmap <buffer> s <Plug>(vimfiler_toggle_mark_selected_lines)
unmap <buffer> d
map <buffer> dd <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_delete_file)
map <buffer> mm <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_move_file)
map <buffer> yy <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_clipboard_copy_file)
map <buffer> x <Plug>(vimfiler_mark_current_line)<Plug>(vimfiler_clipboard_move_file)
map <buffer> p <Plug>(vimfiler_clipboard_paste)

nmap <buffer> <LocalLeader>sh <Plug>(vimfiler_popup_shell)
