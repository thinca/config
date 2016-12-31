#!/bin/zsh

export LANG="ja_JP.UTF-8"
# export XMODIFIERS="@im=SCIM"
# export GTK_IM_MODULE=scim
export XMODIFIERS="@im=ibus"
export GTK_IM_MODULE="ibus"
export QT_IM_MODULE="xim"

which ibus-daemon &>/dev/null && ibus-daemon -d -x

# Start URxvt daemon so we can quickly open the other clients
which urxvtd &>/dev/null && urxvtd -q -o -f

[ -f $HOME/.Xmodmap ] && xmodmap ~/.Xmodmap

# which scim &>/dev/null && scim -d &

which keychain &>/dev/null && eval $(keychain --eval --quiet)

# for $PATH
NOTMUX=1 source ~/.zshrc
LANG=ja_JP.UTF-8

which wicd-client &>/dev/null && wicd-client &

exec ${1:-awesome}
