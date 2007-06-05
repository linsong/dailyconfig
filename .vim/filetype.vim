" my filetype file
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile psql.edit.* setfiletype sql
  au! BufRead,BufNewFile *.lzx      setfiletype lzx
  au! BufRead,BufNewFile nordictrac.dev.exoweb.net_*.txt setfiletype exo-codereview
augroup END
