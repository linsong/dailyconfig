" Copyright (C) 2007 Adrien Friggeri.
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software Foundation,
" Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
" 
" Maintainer:	Adrien Friggeri <adrien@friggeri.net>
" URL:		http://www.friggeri.net/projets/vimblog/
" Version:	0.9
" Last Change:  2007 July 13
"
" Commands :
" ":BlogList"
"   Lists all articles in the blog
" ":BlogNew"
"   Opens page to write new article
" ":BlogOpen <id>"
"   Opens the article <id> for edition
" ":BlogSend"
"   Saves the article to the blog
"
" Configuration : 
"   Edit the "Settings" section (starts at line 51).
"
"   If you wish to use UTW tags, you should install the following plugin : 
"   http://blog.circlesixdesign.com/download/utw-rpc-autotag/
"   and set "enable_tags" to 1 on line 50
"
" Usage : 
"   Just fill in the blanks, do not modify the highlighted parts and everything
"   should be ok.

" Load script once
"------------------------------------------------------------------------------
if exists("loaded_vimpress")
    finish
endif
let loaded_vimpress = 1


" Check python existence
"------------------------------------------------------------------------------
if !has("python")
    finish
endif

command! -nargs=0 BlogList exec("py blog_list_posts()")
command! -nargs=0 BlogNew exec("py blog_new_post()")
command! -nargs=0 BlogSend exec("py blog_send_post()")
command! -nargs=1 BlogOpen exec('py blog_open_post(<f-args>)')

nmap <unique> <silent> ,bl :BlogList<CR>
nmap <unique> <silent> ,bn :BlogNew<CR>
nmap <unique> <silent> ,bs :BlogSend<CR>
nmap <unique> <silent> ,bo :BlogOpen 

let g:Blog_Account = 'vincent'

au BufNewFile,BufRead *.blog set syntax=blogsyntax
au BufNewFile         *.blog :BlogNew

try
python << EOF

import sys
import re
import vim

vim.command("let path = expand('<sfile>:p:h')")
PYPATH = vim.eval('path')
sys.path += [r'%s' % PYPATH]

from blog import *
#import html2text
#import markdown

EOF
catch
    if exists('g:Blog_Password')
        unlet g:Blog_Password
    endif
    :echo "Commands :"
    :echo " :BlogList"
    :echo "   Lists all articles in the blog"
    :echo " :BlogNew"
    :echo "   Opens page to write new article"
    :echo " :BlogOpen <id>"
    :echo "   Opens the article <id> for edition"
    :echo " :BlogSend"
    :echo "   Saves the article to the blog"
endtry
