"so $VIMCFG/ftplugin/xml/xml.vim
runtime! syntax/xml.vim
let b:current_syntax = "lzx"

let commentstring="<!--%s-->"

syn region lzxScript start=+<script>+ end=+</script>+ extend containedin=xmlRegion contains=lzxCData,xmlTag,xmlEqual,xmlEndTag fold keepend

syn region lzxMethod start=+<method+ end=+</method>+ extend containedin=xmlRegion contains=lzxCData,xmlTag,xmlEqual,xmlEndTag fold keepend

syn region lzxEventHandler start=+\Won\w\{-}="+ end=+"+ containedin=xmlTag contains=xmlAttrib,xmlEqual,lzxScriptAttribute,lzxAttributeQuote contained keepend

syn region  lzxScriptAttribute  matchgroup=lzxAttributeQuote start=+="+ end=+"+  contained 

hi link  lzxAttributeQuote           String 

"uncomment these lines to enable syntax folding
"set foldmethod=syntax  
"set foldlevel=2
"highlight Folded guibg=#FFF0F0 guifg=#666688

"tag matching
:source $VIMRUNTIME/macros/matchit.vim
if !exists("b:match_words") |
    \ let b:match_ignorecase=0 | let b:match_words =
    \ '<:>,' .
    \ '<\@<=!\[CDATA\[:]]>,'.
    \ '<\@<=!--:-->,'.
    \ '<\@<=?\k\+:?>,'.
    \ '<\@<=\([^ \t>/]\+\)\%(\s\+[^>]*\%([^/]>\|$\)\|>\|$\):<\@<=/\1>,'.
    \ '<\@<=\%([^ \t>/]\+\)\%(\s\+[^/>]*\|$\):/>'
    \ | endif

"highlights CDATA in a method as a comment
syn match    lzxCData   +<!\[CDATA\[+  contained 
syn match    lzxCData   +]]>+          contained 

hi link  lzxCData           String 

"js comments
syn match   javaScriptLineComment      "\/\/.*$" containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn match   javaScriptCommentSkip      "^[ \t]*\*\($\|[ \t]\+\)"
syn region  javaScriptCommentString    start=+"+  skip=+\\\\\|\\"+  end=+"+ end=+\*/+me=s-1,he=s-1 contains=javaScriptSpecial,javaScriptCommentSkip,@htmlPreproc
syn region  javaScriptComment2String   start=+"+  skip=+\\\\\|\\"+  end=+$\|"+  contains=javaScriptSpecial,@htmlPreproc
syn region  javaScriptComment          start="/\*"  end="\*/" contains=javaScriptCommentString,javaScriptCharacter,javaScriptNumber containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn match   javaScriptSpecial          "\\\d\d\d\|\\." containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn region  javaScriptStringD          start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=javaScriptSpecial,@htmlPreproc containedin=lzxMethod
syn region  javaScriptStringS          start=+'+  skip=+\\\\\|\\'+  end=+'+  contains=javaScriptSpecial,@htmlPreproc containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn match   javaScriptSpecialCharacter "'\\.'" containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn match   javaScriptNumber           "-\=\<\d\+L\=\>\|0[xX][0-9a-fA-F]\+\>" containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptConditional      if else containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptRepeat           while for containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptBranch           break continue switch case default containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptOperator         new in containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptType             super this var parent containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptStatement        return with containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptFunction         function containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn keyword javaScriptBoolean          true false containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn match   javaScriptBraces           "[{}]" containedin=lzxMethod,lzxScriptAttribute,lzxScript

" catch errors caused by wrong parenthesis
syn match   javaScriptInParen     contained "([{}])"
syn region  javaScriptParen       transparent start="(" end=")" contains=javaScriptParen,javaScript.* containedin=lzxMethod,lzxScriptAttribute,lzxScript
syn match   javaScrParenError  ")" containedin=lzxMethod,lzxScriptAttribute

hi def link javaScriptComment           Comment
hi def link javaScriptLineComment       Comment
hi def link javaScriptSpecial           Special
hi def link javaScriptStringS           String
hi def link javaScriptStringD           String
hi def link javaScriptCharacter         Character
hi def link javaScriptSpecialCharacter  javaScriptSpecial
hi def link javaScriptNumber            javaScriptValue
hi def link javaScriptConditional       Conditional
hi def link javaScriptRepeat            Repeat
hi def link javaScriptBranch            Conditional
hi def link javaScriptOperator          Operator
hi def link javaScriptType              Type
hi def link javaScriptStatement         Statement
hi def link javaScriptFunction          Function
hi def link javaScriptBraces            Function
hi def link javaScriptError             Error
hi def link javaScrParenError           javaScriptError
hi def link javaScriptInParen           javaScriptError
hi def link javaScriptBoolean           Boolean

function! CommNode()
    if &foldopen =~ "percent"
      normal! zv
    endif

    let cline = line(".")
    while match( getline(cline) , "<\!\\@!" ) < 0
        let cline = cline -1
        if cline == -1
            break
        endif
    endwhile
    if cline >=0
        let oldline = getline(cline)
        let commtag = matchstr( oldline , "<\\w*" )
        "let nline = substitute( oldline  , "<" , "<!--" , "" )
        "let didrep = setline( cline , nline )
    else
        echo "Couldn't find node to comment."
        return
    endif 
    echo "commtag: " . commtag
endfun

