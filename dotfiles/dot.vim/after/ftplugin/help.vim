scriptencoding utf-8

SetUndoFtplugin setlocal kp<
setlocal keywordprg=:help

SetUndoFtplugin silent! nunmap <C-]>
SetUndoFtplugin silent! vunmap <C-]>
SetUndoFtplugin silent! nunmap <C-w><C-]>
SetUndoFtplugin silent! vunmap <C-w><C-]>
nnoremap <buffer> <C-]> <C-]>zv
vnoremap <buffer> <C-]> <C-]>zv
nnoremap <buffer> <C-w><C-]> <C-w><C-]>
vnoremap <buffer> <C-w><C-]> <C-w><C-]>

function! s:option_to_view()
  setlocal buftype=help nomodifiable readonly
  setlocal nolist
  if exists('+colorcolumn')
    setlocal colorcolumn=
  endif
  if has('conceal')
    setlocal conceallevel=2
  endif
endfunction

function! s:option_to_edit()
  setlocal buftype= modifiable noreadonly
  setlocal list tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab textwidth=78
  if exists('+colorcolumn')
    setlocal colorcolumn=+1
  endif
  if has('conceal')
    setlocal conceallevel=0
  endif
endfunction

command! -buffer -bar HelpEdit call s:option_to_edit()
command! -buffer -bar HelpView call s:option_to_view()

nnoremap <buffer> <silent> <expr> <C-s>
\ ":\<C-u>Help" . (&l:buftype == '' ? 'View' : 'Edit') . "\<CR>"



let s:pattern_link = '|[^ |]\+|'
let s:pattern_option = '''[A-Za-z0-9_-]\{2,}'''
let s:pattern_any = join([s:pattern_link, s:pattern_option], '\|')

" J/K are experimental keys.
" call textobj#user#plugin('help', {
\      'any': {
\        '*pattern*': s:pattern_any,
\        'move-n': '<buffer> <LocalLeader>j',
\        'move-p': '<buffer> <LocalLeader>k',
\        'move-N': '<buffer> <LocalLeader>J',
\        'move-P': '<buffer> <LocalLeader>K',
\      },
\      'link': {
\        '*pattern*': s:pattern_link,
\        'move-n': '<buffer> <LocalLeader>f',
\        'move-p': '<buffer> <LocalLeader>r',
\        'move-N': '<buffer> <LocalLeader>F',
\        'move-P': '<buffer> <LocalLeader>R',
\      },
\      'option': {
\        '*pattern*': s:pattern_option,
\        'move-n': '<buffer> <LocalLeader>d',
\        'move-p': '<buffer> <LocalLeader>e',
\        'move-N': '<buffer> <LocalLeader>D',
\        'move-P': '<buffer> <LocalLeader>E',
\      },
\    })
if &buftype ==# 'help'
  map <buffer> J  <Plug>(textobj-help-any-n)
  map <buffer> K  <Plug>(textobj-help-any-p)
endif



if &buftype ==# 'help'
  finish
endif

" in editing
SetUndoFtplugin setlocal ts< sw< sts< et< cc< tw=78
SetUndoFtplugin delcommand GenerateContents
SetUndoFtplugin unlet! b:smart_expandtab
call s:option_to_edit()

command! -buffer -bar GenerateContents call s:generate_contents()
function! s:generate_contents()
  let cursor = getpos('.')

  let plug_name = expand('%:t:r')
  let ja = expand('%:e') ==? 'jax'
  1

  if search('-contents\*$', 'W')
    silent .+1;/^=\{78}$/-1 delete _
    .-1
    put =''
  else
    keeppatterns /^License:\|Maintainer:/+1
    let header = printf('%s%s*%s-contents*', (ja ? "目次\t" : 'CONTENTS'),
    \            repeat("\t", 5), plug_name)
    silent put =[repeat('=', 78), header, '']
  endif

  let contents_pos = getpos('.')

  let lines = []
  while search('^\([=-]\)\1\{77}$', 'W')
    let head = getline('.') =~# '=' ? '' : '  '
    .+1
    let caption = matchlist(getline('.'), '^\([^\t]*\)\t\+\*\(\S*\)\*$')
    if !empty(caption)
      let [title, tag] = caption[1 : 2]
      call add(lines, printf("%s%s\t%s|%s|", head, title, head, tag))
    endif
  endwhile

  call setpos('.', contents_pos)

  silent put =lines + repeat([''], 3)
  call setpos('.', contents_pos)
  let len = len(lines)
  setlocal expandtab tabstop=32
  execute '.,.+' . len . 'retab'
  setlocal noexpandtab tabstop=8
  execute '.,.+' . len . 'retab!'

  call setpos('.', cursor)
endfunction

function! s:get_text_on_cursor(pat)
  let line = getline('.')
  let pos = col('.')
  let s = 0
  while s < pos
    let [s, e] = [match(line, a:pat, s), matchend(line, a:pat, s)]
    if s < 0
      break
    elseif s < pos && pos <= e
      return line[s : e - 1]
    endif
    let s += 1
  endwhile
  return ''
endfunction

function! s:jump_to_tag() abort
  let tag = s:get_text_on_cursor('|\zs[^|]\+\ze|')
  if tag !=# ''
    let pat = escape(tag, '\')
    call search('\V*\zs' . pat . '*', 'w')
  endif
endfunction
nnoremap <buffer> <silent> <C-]> :<C-u>call <SID>jump_to_tag()<CR>

let b:smart_expandtab = 0
