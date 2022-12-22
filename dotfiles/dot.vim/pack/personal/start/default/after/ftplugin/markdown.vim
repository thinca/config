SetUndoFtplugin setl et< ts< sw<

setlocal expandtab tabstop=2 shiftwidth=2

command! -bar -buffer MarkdownToggleCheck
\ keeppattern substitute/^\s*- \[\zs.\ze\]/\=[' ','x'][submatch(0)==' ']/

nnoremap <silent> <buffer> <Space>c :<C-u>MarkdownToggleCheck<CR>
