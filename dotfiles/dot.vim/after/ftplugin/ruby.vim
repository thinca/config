SetUndoFtplugin setl ts< sw< sts< sta< et< ai< isk<

setlocal tabstop=2 shiftwidth=2 softtabstop=2 smarttab expandtab autoindent
setlocal isk+=? isk+=!

compiler ruby

if filereadable('.rubocop.yml')
  let b:watchdogs_checker_type = 'watchdogs_checker/rubocop'
endif

if expand('%:p') =~# '_spec\.rb$'
  let b:quickrun_config = {
  \   'type': 'ruby/rspec',
  \ }
endif
