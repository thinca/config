if &l:fileencoding !=# 'cp932' || &l:fileformat !=# 'dos'
  setlocal fileencoding=cp932 fileformat=dos
  if search('[^\x00-\x7F]', 'cnw')
    setlocal modified
  endif
endif
