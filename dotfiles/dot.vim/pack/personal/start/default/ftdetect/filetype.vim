autocmd BufReadPost,BufNewFile /etc/httpd/conf.d/*.conf setfiletype apache
autocmd BufReadPost,BufNewFile /etc/apache{2,}/*.d/*.conf setfiletype apache
autocmd BufReadPost,BufNewFile */dot.zsh/* setfiletype zsh

autocmd BufReadPost,BufNewFile Guardfile,*.god       setlocal filetype=ruby
autocmd BufReadPost,BufNewFile *.jam,Jamroot,Jamfile setlocal filetype=jam
autocmd BufReadPost,BufNewFile *.scala               setlocal filetype=scala
autocmd BufReadPost,BufNewFile *.noop                setlocal filetype=noop
autocmd BufReadPost,BufNewFile *.r                   setlocal filetype=r
autocmd BufReadPost,BufNewFile *.wsgi                setlocal filetype=python
autocmd BufReadPost,BufNewFile *.ng                  setlocal filetype=javascript
autocmd BufReadPost,BufNewFile *.hx                  setlocal filetype=haxe
autocmd BufReadPost,BufNewFile *.grass               setlocal filetype=grass
autocmd BufReadPost,BufNewFile *.kt                  setlocal filetype=kotlin
autocmd BufReadPost,BufNewFile Dockerfile.*          setlocal filetype=dockerfile

autocmd BufReadPost,BufNewFile *.json.jb{,uilder}     setlocal filetype=ruby
autocmd BufReadPost,BufNewFile .pryrc                 setlocal filetype=ruby
autocmd BufReadPost,BufNewFile {database,secrets}.yml setlocal filetype=eruby.yaml
autocmd BufReadPost,BufNewFile */config/*.yml         setlocal filetype=eruby.yaml
autocmd BufReadPost,BufNewFile .babelrc               setlocal filetype=json
autocmd BufReadPost,BufNewFile .flowconfig            setlocal filetype=dosini
autocmd BufReadPost,BufNewFile .envrc                 setlocal filetype=sh

autocmd BufReadPost,BufNewFile *.csv             setfiletype csv
autocmd BufReadPost,BufNewFile *.nut             setfiletype squirrel
autocmd BufReadPost,BufNewFile *.bin,*.exe,*.dll setfiletype xxd
autocmd BufReadPost,BufNewFile *.vi,*.vimgolf    setfiletype vimgolf

autocmd BufReadPost,BufNewFile *.txt,README call s:structured_text()
autocmd BufReadPost,BufNewFile *.class call s:detect_javaclass()

function! s:detect_javaclass()
  let file = expand('<afile>')
  if !filereadable(file)
    return
  endif
  let line = readfile(file, 'b', 1)[0]
  if 4 <= strlen(line) && line[:3] == "\xCA\xFE\xBA\xBE"
    setlocal filetype=javaclass
  endif
endfunction

function! s:structured_text()
  if &l:filetype !=# '' && &l:filetype !=# 'text'
    return
  endif
  let line1 = getline(1)
  let line2 = getline(2)
  let &l:filetype  =
  \   line1 =~# '^\([=-`:''"~^_*+#<>]\)\1*$' ? 'rst' :
  \   line1 =~# '^='      ? 'notebook' :
  \   line1 =~# '^h\d\. ' ? 'textile' :
  \   line1 =~# '^#' ||
  \   line2 =~# '^=\+$'   ? 'markdown' :
  \                        'text'
endfunction

