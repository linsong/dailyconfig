if exists("loaded_MH")
  finish
endif
let loaded_MH = 1

command -nargs=1 H !start mh <args>
map K :!start mh <cword> <CR>

