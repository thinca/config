let $DEIN_BASE = expand('~/.local/share/vim/dein')
let $DEIN_REPOS_DIR = expand('$DEIN_BASE/repos/github.com/Shougo/dein.vim')
if !isdirectory($DEIN_REPOS_DIR)
  if !executable('git')
    echo 'Please install git.'
    finish
  endif
  call mkdir(fnamemodify($DEIN_REPOS_DIR, ':h'), 'p')
  call system('git clone https://github.com/Shougo/dein.vim.git ' .
  \   shellescape($DEIN_REPOS_DIR))
  if !isdirectory($DEIN_REPOS_DIR)
    echo 'dein install failed.'
    finish
  endif
endif
set runtimepath^=$DEIN_REPOS_DIR

let g:dein#enable_name_conversion = 1
let g:dein#install_check_diff = 1

function s:update_cmpl(lead, line, pos) abort
  return filter(keys(dein#get()), 'v:val =~# "^" . a:lead')
endfunction
function s:source_cmpl(lead, line, pos) abort
  return keys(filter(dein#get(), 'v:key =~# "^" . a:lead && !v:val.sourced'))
endfunction
function s:call_with_non_empty(func, list) abort
  call call(a:func, empty(a:list) ? [] : [a:list])
endfunction
command! -nargs=* -complete=customlist,s:update_cmpl -bang DeinUpdate
\   call s:call_with_non_empty(
\     (<bang>0 && !empty([<f-args>])) ||
\     get(g:, 'dein#install_github_api_token', '') is# '' ?
\     'dein#update' : funcref('dein#check_update', [v:true]), [<f-args>])
command! -nargs=+ -complete=customlist,s:update_cmpl DeinReinstall
\   call dein#reinstall([<f-args>])
command! -nargs=* -complete=customlist,s:source_cmpl DeinSource
\   call s:call_with_non_empty('dein#source', [<f-args>])
command! DeinRecache call dein#recache_runtimepath()

if !dein#load_state($DEIN_BASE)
  finish
endif

let s:vimrcs = [expand('<sfile>')]

let s:local_dein = expand('~/.config/vim/local.dein.vim')
let s:local_dein_exists = filereadable(s:local_dein)
if s:local_dein_exists
  let s:vimrcs += [s:local_dein]
endif

call dein#begin($DEIN_BASE, s:vimrcs)

if $DROPBOX_HOME !=# ''
  call dein#local($DROPBOX_HOME . '/work/vim-plugins/labs', {'frozen': 1})
endif

call dein#add('Shougo/dein.vim')

function s:try(cmd) abort
  try
    execute a:cmd
    return 1
  catch
    return 0
  endtry
endfunction

" let s:use_deoplete = has('python3') && s:try('python3 import neovim')
" call dein#add('Shougo/deoplete.nvim', {'if': s:use_deoplete})
" call dein#add('roxma/nvim-yarp', {'if': s:use_deoplete})
" call dein#add('roxma/vim-hug-neovim-rpc', {'if': s:use_deoplete})
" call dein#add('prabirshrestha/asyncomplete.vim')
" call dein#add('prabirshrestha/asyncomplete-lsp.vim')
call dein#add('prabirshrestha/vim-lsp')
call dein#add('mattn/vim-lsp-settings')
call dein#add('Shougo/context_filetype.vim')
call dein#add('Shougo/neosnippet.vim')
call dein#add('Shougo/neosnippet-snippets')
call dein#add('Shougo/vimproc.vim', {
\ 'build':
\   has('mac') ? 'make -f make_mac.mak' :
\   has('unix') ? 'make' : ''
\ })
call dein#add('Shougo/vimfiler.vim')
call dein#add('Shougo/unite.vim')
call dein#add('Shougo/neomru.vim')
call dein#add('Shougo/unite-build')
call dein#add('Shougo/vinarise.vim')
call dein#add('Shougo/echodoc', {'lazy': 1})
call dein#add('Shougo/unite-session', {'lazy': 1})
call dein#add('Shougo/unite-outline')

call dein#add('AndrewRadev/linediff.vim')
call dein#add('AndrewRadev/sideways.vim')
call dein#add('vim-scripts/CSApprox', {'lazy': 1})
call dein#add('vim-scripts/Colour-Sampler-Pack', {'lazy': 1})
call dein#add('LeafCage/yankround.vim')
call dein#add('easymotion/vim-easymotion')
call dein#add('Rykka/colorv.vim', {'lazy': 1})
call dein#add('basyura/unite-rails')
call dein#add('cohama/lexima.vim', {'on_event': 'InsertEnter'})
call dein#add('bootleq/vim-cycle', {'lazy': 1})
call dein#add('deris/vim-duzzle', {'on_cmd': 'DuzzleStart'})
call dein#add('deris/vim-operator-insert')
call dein#add('deris/vim-rengbang')
call dein#add('dietsche/vim-lastplace')
call dein#add('eagletmt/onlinejudge-vim', {'lazy': 1})
call dein#add('emanon001/fclojure.vim', {'lazy': 1})
call dein#add('h1mesuke/vim-alignta')
call dein#add('h1mesuke/vim-benchmark')
call dein#add('haya14busa/vim-asterisk')
call dein#add('haya14busa/vim-debugger')
call dein#add('haya14busa/vim-edgemotion')
call dein#add('haya14busa/vim-open-googletranslate')
call dein#add('kana/vim-altr')
call dein#add('kana/vim-fakeclip')
call dein#add('kana/vim-gf-diff')
call dein#add('kana/vim-gf-user')
call dein#add('kana/vim-metarw', {'lazy': 1})
call dein#add('kana/vim-metarw-git')
call dein#add('kana/vim-narrow', {'lazy': 1})
call dein#add('kana/vim-niceblock')
call dein#add('kana/vim-operator-replace')
call dein#add('kana/vim-operator-user')
" call dein#add('kana/vim-repeat', {'lazy': 1})
call dein#add('kana/vim-smartchr')
call dein#add('kana/vim-smartinput', {'lazy': 1})
call dein#add('kana/vim-smartword')
" call dein#add('kana/vim-submode')
call dein#add('kana/vim-textobj-datetime')
call dein#add('kana/vim-textobj-diff')
call dein#add('kana/vim-textobj-entire')
call dein#add('kana/vim-textobj-fold')
call dein#add('kana/vim-textobj-function')
call dein#add('kana/vim-textobj-indent')
call dein#add('kana/vim-textobj-jabraces')
call dein#add('kana/vim-textobj-line')
call dein#add('kana/vim-textobj-syntax')
call dein#add('kana/vim-textobj-user')
call dein#add('previm/previm', {'on_cmd': 'PrevimOpen', 'on_ft': ['markdown', 'textile']})
call dein#add('lambdalisue/vim-findent')
call dein#add('lambdalisue/vim-gita')
call dein#add('lambdalisue/gina.vim')
call dein#add('lambdalisue/vim-gista')
call dein#add('lambdalisue/vim-gista-unite')
call dein#add('lambdalisue/suda.vim')
call dein#add('andymass/vim-matchup')
call dein#add('machakann/vim-sandwich')
call dein#add('mattn/calendar-vim')
call dein#add('mattn/flappyvird-vim')
call dein#add('mattn/gist-vim')
call dein#add('mattn/ideone-vim')
call dein#add('mattn/unite-advent_calendar')
call dein#add('mattn/webapi-vim')
call dein#add('mattn/wwwrenderer-vim')
call dein#add('mfumi/ProjectEuler.vim', {'lazy': 1})
call dein#add('nathanaelkane/vim-indent-guides', {'lazy': 1})
call dein#add('osyo-manga/shabadou.vim')
call dein#add('osyo-manga/unite-quickfix')
call dein#add('osyo-manga/vim-automatic', {'lazy': 1})
call dein#add('osyo-manga/vim-budou', {'lazy': 1})
call dein#add('osyo-manga/vim-chained')
call dein#add('osyo-manga/vim-over', {'lazy': 1})
call dein#add('osyo-manga/vim-precious', {'lazy': 1})
call dein#add('osyo-manga/vim-reanimate')
call dein#add('osyo-manga/vim-reti')
call dein#add('osyo-manga/vim-textobj-multitextobj')
call dein#add('pocket7878/curses-vim')
call dein#add('pocket7878/presen-vim', {'lazy': 1})
call dein#add('rbtnn/puyo.vim', {'on_cmd': 'Puyo'})
call dein#add('rbtnn/vimconsole.vim')
call dein#add('rhysd/clever-f.vim')
call dein#add('rhysd/committia.vim')
call dein#add('rhysd/github-complete.vim')
call dein#add('rhysd/try-colorscheme.vim', {'on_cmd': 'TryColorscheme'})
call dein#add('rhysd/vim-grammarous')
call dein#add('sgur/unite-qf')
call dein#add('sgur/vim-gf-autoload')
call dein#add('sgur/vim-textobj-parameter')
call dein#add('mbbill/undotree', {'on_cmd': 'UndotreeToggle'})
call dein#add('soh335/unite-qflist')
call dein#add('vim-scripts/squirrel.vim')
call dein#add('syngan/vim-vimlint')
call dein#add('t9md/vim-choosewin', {'lazy': 1})
call dein#add('t9md/vim-quickhl')
call dein#add('thinca/vim-ambicmd')
call dein#add('thinca/vim-befunge', {'on_cmd': 'Befunge'})
call dein#add('thinca/vim-blink1')
call dein#add('thinca/vim-breadcrumbs')
call dein#add('thinca/vim-editvar')
call dein#add('thinca/vim-fontzoom')
call dein#add('thinca/vim-ft-clojure')
call dein#add('thinca/vim-ft-diff_fold')
call dein#add('thinca/vim-ft-help_fold')
call dein#add('thinca/vim-ft-markdown_fold')
call dein#add('thinca/vim-ft-rst_header')
call dein#add('thinca/vim-ft-svn_diff')
call dein#add('thinca/vim-ft-vim_fold')
call dein#add('thinca/vim-github')
call dein#add('thinca/vim-ikaring', {'on_cmd': 'Ikaring'})
call dein#add('thinca/vim-localrc')
call dein#add('thinca/vim-logcat', {'on_cmd': 'LogCat'})
call dein#add('thinca/vim-nind')
call dein#add('thinca/vim-openbuf')
call dein#add('thinca/vim-operator-sequence')
call dein#add('thinca/vim-painter', {'lazy': 1})
call dein#add('thinca/vim-partedit')
call dein#add('thinca/vim-plz_donate', {'lazy': 1})
call dein#add('thinca/vim-portal', {'lazy': 1})
call dein#add('thinca/vim-poslist')
call dein#add('thinca/vim-prettyprint')
call dein#add('thinca/vim-qfhl')
call dein#add('thinca/vim-qfreplace')
call dein#add('thinca/vim-quickmemo')
call dein#add('thinca/vim-quickrun', {'rev': 'develop'})
call dein#add('thinca/vim-ref')
call dein#add('thinca/vim-rtputil')
call dein#add('thinca/vim-scall')
call dein#add('thinca/vim-scouter')
call dein#add('thinca/vim-showtime', {'rev': 'develop'})
call dein#add('thinca/vim-singleton', {'rev': 'develop'})
call dein#add('thinca/vim-splash', {'lazy': 1})
call dein#add('thinca/vim-submode', {'rev': 'my-master'})
call dein#add('thinca/vim-template')
call dein#add('thinca/vim-textobj-between')
call dein#add('thinca/vim-textobj-comment')
call dein#add('thinca/vim-textobj-function-javascript')
call dein#add('thinca/vim-textobj-function-perl')
call dein#add('thinca/vim-themis', {'rev': 'develop'})
call dein#add('thinca/vim-threes', {'on_cmd': ['ThreesStart', 'ThreesShowRecord']})
call dein#add('thinca/vim-unite-history')
call dein#add('thinca/vim-winenv')
call dein#add('thinca/vim-wtrans')
call dein#add('thinca/vim-zenspace')
call dein#add('tpope/vim-repeat')
call dein#add('tsukkee/lingr-vim')
call dein#add('tsukkee/unite-help')
call dein#add('tsukkee/unite-tag')
call dein#add('tyru/capture.vim')
call dein#add('tyru/caw.vim')
call dein#add('tyru/current-func-info.vim', {'lazy': 1})
call dein#add('tyru/emap.vim')
call dein#add('tyru/nextfile.vim')
call dein#add('tyru/open-browser.vim')
call dein#add('tyru/open-browser-github.vim')
call dein#add('tyru/operator-camelize.vim')
call dein#add('tyru/operator-html-escape.vim')
call dein#add('tyru/operator-reverse.vim')
call dein#add('tyru/restart.vim')
call dein#add('tyru/savemap.vim')
call dein#add('tyru/simpletap.vim', {'lazy': 1})
call dein#add('tyru/urilib.vim')
call dein#add('tyru/vice.vim')
call dein#add('ujihisa/neco-look')
call dein#add('ujihisa/neoclojure.vim')
call dein#add('ujihisa/ref-hoogle')
call dein#add('ujihisa/shadow.vim')
call dein#add('ujihisa/unite-colorscheme')
call dein#add('ujihisa/unite-font')
call dein#add('ujihisa/unite-locate')
call dein#add('vim-scripts/uptime.vim')
call dein#add('vim-jp/autofmt')
call dein#add('vim-jp/vimdoc-ja')
call dein#add('vim-jp/vital.vim', {'merged': 0})
call dein#add('vim-jp/vim-vimlparser')
call dein#add('ynkdir/vim-funlib')
call dein#add('y0za/vim-reading-vimrc')
call dein#add('yomi322/neco-tweetvim')
call dein#add('yomi322/unite-tweetvim')
call dein#add('yomi322/vim-operator-suddendeath')
call dein#add('obcat/vim-hitspop')
call dein#add('junegunn/vim-easy-align', {'on_cmd': 'EasyAlign'})

call dein#add('tweekmonster/helpful.vim')

call dein#add('itchyny/calendar.vim', {'lazy': 1, 'name': 'itchyny-calendar'})

call dein#add('vim-skk/eskk.vim')
call dein#add('vim-skk/skkdict.vim')

" denops
call dein#add('vim-denops/denops.vim')
call dein#add('vim-skk/denops-skkeleton.vim')

call dein#add('Shougo/ddc.vim')
call dein#add('Shougo/ddc-around')
call dein#add('matsui54/ddc-buffer')
call dein#add('LumaKernel/ddc-file')
call dein#add('octaltree/cmp-look')
call dein#add('shun/ddc-vim-lsp')
call dein#add('Shougo/ddc-matcher_head')
call dein#add('Shougo/ddc-sorter_rank')


" For OmniSharp
call dein#add('tpope/vim-dispatch', {'lazy': 1})
call dein#add('ctrlpvim/ctrlp.vim')
call dein#add('junegunn/vader.vim', {'on_cmd': 'Vader'})

" Games
call dein#add('katono/rogue.vim', {'on_cmd': ['Rogue', 'RogueScores', 'RogueRestore', 'RogueResume']})
call dein#add('vim/killersheep', {'on_cmd': ['KillKillKill']})

" filetype
call dein#add('vim-python/python-syntax')
call dein#add('othree/html5.vim')
" My ghc-mod is broken...
" call dein#add('eagletmt/ghcmod-vim', {'on_ft': 'haskell'})
call dein#add('kana/vim-filetype-haskell')
call dein#add('ujihisa/neco-ghc', {'on_ft': 'haskell'})
call dein#add('derekwyatt/vim-scala', {'on_ft': 'scala'})
call dein#add('vim-scripts/groovyindent')
call dein#add('OmniSharp/omnisharp-vim', {
\   'on_ft': ['cs', 'csharp'],
\   'build':
\     has('win32') ? 'omnisharp-roslyn/build.cmd'
\                  : 'bash omnisharp-roslyn/build.sh || true',
\ })
call dein#add('kchmck/vim-coffee-script')
call dein#add('elzr/vim-json')
call dein#add('leafo/moonscript-vim')
call dein#add('pangloss/vim-javascript')
call dein#add('jsx/jsx.vim', {'on_ft': 'jsx'})
call dein#add('mattn/vim-goimports')
call dein#add('zah/nimrod.vim')
call dein#add('vim-scripts/jam.vim')
call dein#add('Rykka/riv.vim', {'on_ft': 'rst'})
call dein#add('timcharper/textile.vim')
call dein#add('kongo2002/fsharp-vim')
" call dein#add('honza/dockerfile.vim', {'on_ft': 'dockerfile'})
call dein#add('rust-lang/rust.vim', {'on_ft': 'rust'})
call dein#add('racer-rust/vim-racer', {'on_ft': 'rust'})
call dein#add('elixir-lang/vim-elixir')
call dein#add('peitalin/vim-jsx-typescript')
call dein#add('Matt-Deacalion/vim-systemd-syntax')
" call dein#add('vim-jp/vim-go-extra', {'on_ft': 'go'})
call dein#add('tmux-plugins/vim-tmux')
call dein#add('cespare/vim-toml')
call dein#add('udalov/kotlin-vim')
call dein#add('rhysd/vim-gfm-syntax')
call dein#add('jparise/vim-graphql')
call dein#add('slim-template/vim-slim')
call dein#add('pocke/iro.vim', {
\   'build': 'bundle install',
\   'if': has('ruby'),
\   'rev': 'iro-with-vim-syntax',
\ })
call dein#add('chr4/nginx.vim')
call dein#add('nfnty/vim-nftables')
call dein#add('rbtnn/vim-vimscript_indentexpr')

" colorscheme
call dein#add('romainl/Apprentice')
call dein#add('rhysd/vim-color-splatoon')
call dein#add('gruvbox-community/gruvbox')

" library
call dein#add('haya14busa/vital-vimlcompiler')
call dein#add('haya14busa/vital-power-assert')

" Trial use
call dein#add('machakann/vim-vimhelplint')

if s:local_dein_exists
  execute 'source' fnameescape(s:local_dein)
endif

call dein#end()

call dein#save_state()

if dein#check_install()
  call dein#install()
endif

if !empty(map(dein#check_clean(), 'delete(v:val, "rf")'))
  call dein#recache_runtimepath()
endif
