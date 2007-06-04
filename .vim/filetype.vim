" my filetype file
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile psql.edit.* setfiletype sql
  au! BufRead,BufNewFile *.lzx      setfiletype lzx
augroup END
