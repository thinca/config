SetUndoFtplugin setl cin< et< cms<
SetUndoFtplugin iunmap <buffer> (
SetUndoFtplugin iunmap <buffer> )
SetUndoFtplugin iunmap <buffer> <Tab>
SetUndoFtplugin iunmap <buffer> <C-h>
SetUndoFtplugin iunmap <buffer> <Space>

setlocal shiftwidth=2
setlocal nocindent expandtab commentstring=;\ %s
setlocal omnifunc=neoclojure#complete

function! s:get_syntax_name()
  let col = col('.')
  if col == col('$')
    let col -= 1
  endif
  return synIDattr(synIDtrans(synID(line("."), col, 1)), 'name')
endfunction

function! s:is_disable_pare_assist()
  let synname = s:get_syntax_name()
  return synname ==? 'Constant' || synname ==? 'Comment'
endfunction

function! s:pair_char(char)
  return get({
  \   '(': ')', '{': '}', '[': ']',
  \   ')': '(', '}': '{', ']': '[',
  \ }, a:char, '')
endfunction

function! s:prev_char()
  return getline('.')[col('.') - 2]
endfunction

function! s:next_char()
  return getline('.')[col('.') - 1]
endfunction

function! s:overwrap_pare(left, right)
  let next = s:next_char()
  let g:next = next
  let g:disable = s:is_disable_pare_assist()
  if s:is_disable_pare_assist()
    return a:left
  elseif next =~# '^[({[]$'
    return printf("%s\<C-o>%%\<Right>%s\<ESC>%%a", a:left, a:right)
  elseif next =~# '\k'
    return printf("\<ESC>ea%s\<Left>\<C-o>b%s", a:right, a:left)
  endif
  return a:left . a:right . "\<Left>"
endfunction

function! s:skip_close_pare(defkey, altkey, char)
  if !s:is_disable_pare_assist() && s:next_char() ==# a:char
    return a:altkey
  endif
  return a:defkey
endfunction

function! s:wrap_tab()
  let tab = TabWrapper()
  if s:is_disable_pare_assist() ||
  \  tab ==# "\<Plug>(neocomplcache_snippets_jump)"
    return tab
  endif
  let ch = s:next_char()
  if ch =~# '^[({[]$'
    return "\<C-o>%\<Right>"
  elseif ch =~# '^[]})]$'
    return s:skip_close_pare(tab, "\<Right>", ch)
  endif
  return tab
endfunction

function! s:del_pare(defkey)
  let prev = s:prev_char()
  if !s:is_disable_pare_assist()
    if prev =~# '^[({[]$'
      return a:defkey . s:skip_close_pare('', "\<Del>", s:pair_char(prev))
    elseif prev =~# '^[]})]$'
      " TODO
    endif
  endif
  return a:defkey
endfunction

function! s:smart_space(key)
  let prev = s:prev_char()
  let next = s:next_char()
  if prev ==# ' ' && next !=# ' '
    return a:key . "\<Left>"
  endif
  return a:key
endfunction


inoremap <buffer> <expr> ( <SID>overwrap_pare('(', ')')
inoremap <buffer> <expr> [ <SID>overwrap_pare('[', ']')
inoremap <buffer> <expr> { <SID>overwrap_pare('{', '}')

imap <buffer> <expr> <Tab> <SID>wrap_tab()

inoremap <buffer> <expr> ) <SID>skip_close_pare(')', "\<Right>", ')')
inoremap <buffer> <expr> ] <SID>skip_close_pare(']', "\<Right>", ']')
inoremap <buffer> <expr> } <SID>skip_close_pare('}', "\<Right>", '}')

inoremap <buffer> <expr> <C-h> <SID>del_pare("\<C-H>")

inoremap <buffer> <expr> <Space> <SID>smart_space(' ')
