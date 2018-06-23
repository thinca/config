SetUndoFtplugin setl et< ts<

setlocal expandtab tabstop=2

command! -bar -buffer MarkdownToggleCheck
\ keeppattern substitute/^\s*- \[\zs.\ze\]/\=[' ','x'][submatch(0)==' ']/

nnoremap <silent> <buffer> <Space>c :<C-u>MarkdownToggleCheck<CR>
