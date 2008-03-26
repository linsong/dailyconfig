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
  au! BufRead,BufNewFile nordicbet.dev.exoweb.net*.txt setfiletype exo-codereview
  au! BufRead,BufNewFile *.txt      setfiletype txt

  au! BufRead,BufNewFile *.mkd      setfiletype mkd
  au! BufRead,BufNewFile *.blogger  setfiletype blogger

  au! BufRead,BufNewFile *.viki  setfiletype viki

  au  BufRead,BufNewFile ipython_edit*.py set paste
  au  BufRead,BufNewFile svn-commit.tmp set paste
  "au  BufRead,BufNewFile mutt-vincent-* set paste

  au! BufRead,BufNewFile *.rest  setfiletype rest
  au! BufRead,BufNewFile *.vst  setfiletype rest

  au BufNewFile,BufRead *.moin setf moin
  au BufNewFile,BufRead *.wiki setf moin
augroup END
