if exists('b:current_syntax')
  finish
endif

syntax include @clojureCode syntax/clojure.vim
syntax match cljPrompt '^[[:alnum:]_.]\+=>' nextgroup=clojureCode
syntax match clojureCode ".*\n" contained contains=@clojureCode
syntax region clojureCode start="(" end=")" contained contains=@clojureCode

highlight default link cljPrompt Identifier

let b:current_syntax = 'int-clj'
