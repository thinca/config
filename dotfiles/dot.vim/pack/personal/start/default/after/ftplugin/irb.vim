SetUndoFtplugin setl buftype<
SetUndoFtplugin iunmap <buffer> <CR>
SetUndoFtplugin iunmap <buffer> <C-l>
SetUndoFtplugin unlet! b:irb_pos b:irb_eval b:popup_close

runtime! syntax/ruby.vim indent/ruby.vim ftplugin/ruby.vim ftplugin/ruby_*.vim ftplugin/ruby/*.vim
setl buftype=nofile indentexpr=GetRubyIndent()

function s:closePopup()
  let b:popup_close = pumvisible()
  return "\<CR>"
endfunction

function s:evalRuby()
  if b:popup_close
    return ''
  endif
  let b:irb_eval .= getline(line('.') - 1) . "\n"
  if indent('.') == 0
    try
      ruby $curbuf.line = "=> " + eval(VIM::evaluate('b:irb_eval')).inspect
    catch
      d
      call append(line('.'), '# ' . v:exception)
      normal! j
    endtry
    let b:irb_eval = ''
    return "\<ESC>o\<ESC>0Di"
  endif
  return ''
endfunction

let b:irb_eval = ''

inoremap <buffer> <silent> <CR> <C-o>A<C-r>=<SID>closePopup()<CR><C-r>=<SID>evalRuby()<CR>
inoremap <buffer> <silent> <C-l> <C-o>:%d _<CR>

startinsert
