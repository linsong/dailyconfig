" my filetype file
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile psql.edit.* setfiletype sql
  " to make pasting sql query into editor of psql easier, turn on 'paste' by default
  au  BufRead,BufNewFile psql.edit.* set paste
  au! BufRead,BufNewFile *.lzx      setfiletype lzx
  au! BufRead,BufNewFile nordictrac.dev.exoweb.net_*.txt setfiletype exo-codereview

  au! BufRead,BufNewFile *.mkd      setfiletype mkd
  au! BufRead,BufNewFile *.blogger  setfiletype blogger

  au! BufRead,BufNewFile *.viki  setfiletype viki
augroup END
