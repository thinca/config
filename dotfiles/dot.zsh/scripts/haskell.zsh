#     Haskell cabal
path=(~/.cabal/bin(N-/) $path)

# href - reference for haskell
export HREF_DATADIR=~/share/doc/href
compctl -K _href href
functions _href() {
	reply=($(cat $HREF_DATADIR/comptable|awk -F, '{print $2}'|sort|uniq))
}

alias -s hs=runghc
