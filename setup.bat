@echo off

goto :main

:link
del %1 2>nul
mklink %1 %2
goto :EOF

:dlink
rmdir %1 2>nul
mklink /d %1 %2
goto :EOF

:main
setlocal

set HOME=%HOMEDRIVE%%HOMEPATH%
set CONFIG=%~dp0
set DOTFILES=%CONFIG%dotfiles

if exist %DOTFILES%\dot.config (
  if not exist %HOME%\.config mkdir %HOME%\.config
  pushd %HOME%\.config
  call :dlink wtrans %DOTFILES%\dot.config\wtrans
  popd
)

pushd %HOME%

call :link .vimperatorrc %CONFIG%\firefox\dot.vimperatorrc
call :dlink vimperator %CONFIG%\firefox\vimperator
set VIMPERATOR_PLUGINS=%HOME%\.local\share\vimperator\plugins\
if not exist %VIMPERATOR_PLUGINS% git clone https://github.com/vimpr/vimperator-plugins %VIMPERATOR_PLUGINS%

call :link _nya %CONFIG%\windows\ckw\_nya

call :link .gitconfig %DOTFILES%\dot.gitconfig
call :link .gitignore %DOTFILES%\dot.gitignore
call :link .hgrc %DOTFILES%\dot.hgrc
call :link .hgignore %DOTFILES%\dot.hgignore
call :link .inputrc %DOTFILES%\dot.inputrc
call :link .irbrc %DOTFILES%\dot.irbrc
call :dlink vimfiles %DOTFILES%\dot.vim

popd

endlocal

pause
