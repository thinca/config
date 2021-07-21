
function breadcrumbs#update() abort
  let items = s:search_breadcrumbs_items(line('.'))
  if exists('b:breadcrumbs_converter')
    call map(items, { _, item -> [item[0], b:breadcrumbs_converter(item[1])] })
  else
    call map(items, { _, item -> [item[0], substitute(item[1], '^\s*', '', '')] })
  endif
  call filter(items, { _, item -> item[1] !=# '' })

  call breadcrumbs#show(items)
endfunction

function breadcrumbs#remove() abort
  if exists('w:breadcrumbs_items')
    for prev_item in w:breadcrumbs_items
      execute 'nunmenu WinBar.' . prev_item[1]
    endfor
    unlet w:breadcrumbs_items
  endif
endfunction

function breadcrumbs#show(items) abort
  let items = mapnew(a:items, { _, item -> [item[0], escape(item[1], ' .|')] })
  if exists('w:breadcrumbs_items')
    if w:breadcrumbs_items == items
      return
    endif
    for prev_item in w:breadcrumbs_items
      execute 'nunmenu WinBar.' . prev_item[1]
    endfor
  endif
  let w:breadcrumbs_items = items
  if empty(items)
    return
  endif
  let n = 100
  for [lnum, menu] in items
    execute printf('nnoremenu 1.%d WinBar.%s %dG', n, menu, lnum)
    let n += 1
  endfor
endfunction

function breadcrumbs#on() abort
  augroup vimrc-breadcrumbs
    autocmd! * <buffer>
    autocmd CursorMoved <buffer> call breadcrumbs#update()
  augroup END
  call breadcrumbs#update()
endfunction

function breadcrumbs#off() abort
  augroup vimrc-breadcrumbs
    autocmd! * <buffer>
  augroup END
  call breadcrumbs#remove()
endfunction

function s:search_breadcrumbs_items(lnum) abort
  let lnum = prevnonblank(a:lnum)
  let view = winsaveview()
  let items = []
  while lnum
    let indent = indent(lnum) - 1
    if indent <= 0
      break
    endif
    " TODO: tab indent
    let lnum = search('^ \{0,' . indent . '}\S', 'bW')
    if lnum
      let items += [[lnum, getline(lnum)]]
    endif
  endwhile
  call winrestview(view)
  return reverse(items)
endfunction
