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

pushd %HOME%

call :link .vimperatorrc %CONFIG%\firefox\dot.vimperatorrc
call :dlink vimperator %CONFIG%\firefox\vimperator
rem TODO git clone https://github.com/vimpr/vimperator-plugins ~/.local/share/vimperator/plugins

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
