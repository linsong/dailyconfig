" tagedit.vim 
" Acknowledgements:
"   this plugin comes from
"       http://www.vim.org/tips/tip.php?tip_id=346
"   contributed by Fish burn      
"   This plugin applies for editing html/xml/xsl/lzx that include tags 
"   in the file.

if ! exists("b:tagedit")
    let b:tagedit = 1

    "Use nmap, not nnoremap, since we do want to use an existing mapping
    nmap <buffer> ,,, viw,,,
    vnoremap <buffer> ,,, <Esc>:call TagSelection()<CR>

    "to make some minor corrections to the map to handle 1 character tags:
    inoremap <buffer> ,,, <esc>diwi<<esc>pa><cr></<esc>pa><esc>kA 
endif

" prevent reloading twice for the same type of file 
if exists("g:tagedit")
    finish
endif

function! TagSelection()
  let tag = input("Tag name (include attributes)? ")

  if strlen(tag) == 0
      return
  endif

  " Save b register
  let saveB       = @b
  " <C-R> seems to automatically reindent the line for some filetypes
  " this will disable it until we have applied our changes
  let saveIndent  = &indentexpr
  let curl        = line(".")
  let curc        = col(".")
  let &indentexpr = ''

  " If the visual selection is over multiple lines, then place the
  " data between the tags on newlines:
  "    <tag>
  "    data
  "    </tag>
  let newline = ''
  if getline("'>") != getline("'<")
      let newline = "\n"
      let curl  = line("'>")
  endif

  " Strip off all but the first word in the tag for the end tag
  let @b = newline . substitute( tag, '^[ \t"]*\(\<\S*\>\).*', '<\/\1>\e', "" )
  let curc = curc + strlen(@b)
  exec "normal `>a\<C-R>b"

  let @b = substitute( tag, '^[ \t"]*\(\<.*\)', '<\1>\e', "" ) . newline
  let curc = curc + strlen(@b)
  exec "normal `<i\<C-R>b"

  " Now format the area
  exec "normal `<V'>j="

  " Restore b register
  let @b          = saveB
  let &indentexpr = saveIndent

  call cursor(curl, curc)
endfunction 
