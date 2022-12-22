SetUndoFtplugin setl et< ts< sw< sts<

setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=-1

command! -bar -buffer MarkdownToggleCheck
\ keeppattern substitute/^\s*- \[\zs.\ze\]/\=[' ','x'][submatch(0)==' ']/

nnoremap <silent> <buffer> <Space>c :<C-u>MarkdownToggleCheck<CR>
