SetUndoFtplugin setl cin< et< cms<
SetUndoFtplugin iunmap <buffer> (
SetUndoFtplugin iunmap <buffer> )
SetUndoFtplugin iunmap <buffer> <Tab>
SetUndoFtplugin iunmap <buffer> <C-h>

setlocal nocindent expandtab commentstring=;\ %s

" 現在位置の構文グループの名前。リンクは解決済み
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

" 開き括弧の直前で(を押した時、既にある括弧全体を囲む
" そうでなければ()にして間にカーソルを置く
" ただし文字列中やコメント中は何もしない
function! s:overwrap_pare()
  let ch = getline('.')[col('.') - 1]
  if s:is_disable_pare_assist()
    return '('
  elseif ch == '('
    return "\<C-o>%)\<C-o>h\<C-o>%("
  elseif ch =~ '\k'
    return "\<ESC>ea)\<Left>\<C-o>b("
  endif
  return "()\<Left>"
endfunction

" 次の文字が ')' だった時指定したキーを押す
function! s:skip_close_pare(defkey, altkey)
  if !s:is_disable_pare_assist() && getline('.')[col('.') - 1] == ')'
    return a:altkey
  endif
  return a:defkey
endfunction

function! s:wrap_tab()
  let tab = "\<Tab>"
  if s:is_disable_pare_assist()
    return tab
  endif
  let ch = getline('.')[col('.') - 1]
  if ch == '('
    return "\<C-o>%\<Right>"
  elseif ch == ')'
    return s:skip_close_pare(tab, "\<Right>")
  endif
  return tab
endfunction

" ()の真ん中で指定キーを押した時)を消す
function! s:del_pare(defkey)
  if !s:is_disable_pare_assist() && getline('.')[col('.') - 2] == '('
    return a:defkey . s:skip_close_pare('', "\<Del>")
  endif
  return a:defkey
endfunction

" 閉じ括弧も同時入力
inoremap <buffer> <expr> ( <SID>overwrap_pare()
" タブで閉じ括弧をスキップ
inoremap <buffer> <expr> <Tab> <SID>wrap_tab()
" )でも余計にはさまずスキップ(使いづらかったら削除)
inoremap <buffer> <expr> ) <SID>skip_close_pare(")", "\<Right>")

" ()の真ん中で(を消した時)も消す
inoremap <buffer> <expr> <C-h> <SID>del_pare("\<C-H>")
