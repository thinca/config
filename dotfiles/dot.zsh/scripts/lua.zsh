# luarocks
if which luarocks &>/dev/null; then
	eval $(luarocks path)
fi
export LUA_PATH="$LUA_PATH;$HOME/.luarocks/share/lua/5.1/?.lua"
export LUA_CPATH="$LUA_PATH;$HOME/.luarocks/lib/lua/5.1/?.so"
