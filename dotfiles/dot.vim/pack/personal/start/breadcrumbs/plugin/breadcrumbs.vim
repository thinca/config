if exists('g:loaded_breadcrumbs')
  finish
endif
let g:loaded_breadcrumbs = 1

command! -bar BreadcrumbsOn call breadcrumbs#on()
command! -bar BreadcrumbsOff call breadcrumbs#off()
command! -bar BreadcrumbsRemove call breadcrumbs#remove()
command! -bar BreadcrumbsUpdate call breadcrumbs#update()
