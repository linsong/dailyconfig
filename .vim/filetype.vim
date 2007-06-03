" my filetype file
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.mine		setfiletype mine
  au! BufRead,BufNewFile *.xyz		setfiletype drawing
  au! BufRead,BufNewFile psql.edit.* setfiletype sql
augroup END
