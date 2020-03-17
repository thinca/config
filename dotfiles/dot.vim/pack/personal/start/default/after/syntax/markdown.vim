let s:current_syntax = get(b:, 'current_syntax', '')
unlet! b:current_syntax
syntax include @markdownYAML syntax/yaml.vim
syntax region markdownYAMLHeader matchgroup=PreProc start='\%1l\%1c---\n' end='\n---$' contains=@markdownYAML

syn region markdownCode matchgroup=markdownBlockDelimiter start=+^```$+ end=+^```$+

let b:markdown_syntax_code_loaded = {}  " Reset when load.
function! s:update_code()
  let mx = '^```\zs.\+$'
  for curline in getline(1, '$')
    let ft = matchstr(curline, mx)
    if ft !=# '' && !has_key(b:markdown_syntax_code_loaded, ft)
    \ && globpath(&runtimepath, 'syntax/' . ft . '.vim') !=# ''
      unlet! b:current_syntax
      let save_isk = &l:iskeyword  " For scheme.
      execute printf('syntax include @markdownCode_%s syntax/%s.vim',
      \ ft, ft)
      let &l:iskeyword = save_isk

      execute printf('syntax region markdownCodePre '
      \ . 'matchgroup=markdownBlockDelimiter start="^```%s$" end="^```$" '
      \ . 'contains=@markdownCode_%s', ft, ft)

      let b:markdown_syntax_code_loaded[ft] = 1
    end
  endfor
  " workaround for perl
  syntax cluster MarkdownCode_perl remove=perlFunctionName
  syntax sync fromstart
endfunction

command! -buffer -bar MarkdownCodeUpdate call s:update_code()
" MarkdownCodeUpdate

highlight link markdownBlockDelimiter Delimiter

syntax sync fromstart

if s:current_syntax !=# ''
  let b:current_syntax = s:current_syntax
endif
