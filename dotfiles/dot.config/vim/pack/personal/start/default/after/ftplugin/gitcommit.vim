if &l:modifiable && (&l:fileencoding !=# 'utf-8' || &l:fileformat !=# 'unix')
  setlocal fileencoding=utf-8 fileformat=unix
  setlocal modified
endif
