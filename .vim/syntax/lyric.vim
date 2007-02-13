if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


" shut case off
syn case ignore

highlight WordBreak ctermfg=red guifg=red ctermbg=cyan guibg=cyan
highlight SecBreak ctermfg=black guifg=black ctermbg=LightCyan guibg=LightCyan
highlight Hypen ctermfg=white guifg=white ctermbg=brown guibg=brown
highlight BarBreak ctermfg=black guifg=black ctermbg=blue guibg=blue

syn match   WordBreak        "\^"
syn region 	SecBreak        start="\[" end="\]"
syn region  BarBreak        start="<" end=">"
syn match   Hypen           "-"

let b:current_syntax="lyric"


