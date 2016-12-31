function! GetCsFold(lnum)
  let line = getline(v:lnum)
  if line =~# '^\s*#region'
    return 'a1'
  elseif line =~# '^\s*#endregion'
    return 's1'
  endif
  return '='
endfunction

setlocal foldmethod=expr foldexpr=GetCsFold(v:lnum)

let b:caw_oneline_comment = '//'

if empty(globpath(&runtimepath, 'autoload/OmniSharp.vim'))
  finish
end

nnoremap <silent> <buffer> <F2>  :OmniSharpRename<CR>
nnoremap <silent> <buffer> <F3>  :OmniSharpTypeLookup<CR>
nnoremap <silent> <buffer> <F5>  :OmniSharpReloadSolution<CR>
nnoremap <silent> <buffer> <F7>  :OmniSharpBuild<CR>
nnoremap <silent> <buffer> <F11> :OmniSharpFindImplementations<cr>
nnoremap <silent> <buffer> <F12> :OmniSharpGotoDefinition<CR>
nnoremap <silent> <buffer> <S-F12> :OmniSharpFindUsages<CR>

nnoremap <silent> <buffer> K :OmniSharpDocumentation<CR>

nnoremap <silent> <buffer> ma :OmniSharpAddToProject<CR>
nnoremap <silent> <buffer> mb :OmniSharpBuild<CR>
nnoremap <silent> <buffer> mc :OmniSharpFindSyntaxErrors<CR>
nnoremap <silent> <buffer> mf :OmniSharpCodeFormat<CR>
nnoremap <silent> <buffer> mj :OmniSharpGotoDefinition<CR>
nnoremap <silent> <buffer> <C-w>mj <C-w>s:OmniSharpGotoDefinition<CR>
nnoremap <silent> <buffer> mi :OmniSharpFindImplementations<CR>
nnoremap <silent> <buffer> mr :OmniSharpRename<CR>
nnoremap <silent> <buffer> mt :OmniSharpTypeLookup<CR>
nnoremap <silent> <buffer> mu :OmniSharpFindUsages<CR>
nnoremap <silent> <buffer> mx :OmniSharpGetCodeActions<CR>

nnoremap <silent> <buffer> gd :OmniSharpGotoDefinition<CR>
nnoremap <silent> <buffer> <C-w>gd <C-w>s:OmniSharpGotoDefinition<CR>
nnoremap <silent> <buffer> gr :OmniSharpFindUsages<CR>
