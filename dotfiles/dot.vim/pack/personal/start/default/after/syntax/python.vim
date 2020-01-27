syntax region pythonFormatString matchgroup=pythonQuotes
\ start=+[fF]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
\ contains=pythonEscape,pythonFormatEscape,pythonFormat,@Spell
syntax region pythonFormatString matchgroup=pythonQuotes
\ start=+[fF]\z('''\|"""\)+ end="\z1" keepend
\ contains=pythonEscape,pythonSpaceError,pythonDoctest,pythonFormatEscape,pythonFormat,@Spell
syntax match pythonFormatEscape '{{'
syntax match pythonFormatEscape '}}'
syntax region pythonFormat matchgroup=pythonFormatDelimiter
\ start=+{{\@!+ end=+}+
\ contains=TOP contained


highlight default link pythonFormatString String
highlight default link pythonFormatEscape pythonEscape
highlight default link pythonFormatDelimiter Delimiter
