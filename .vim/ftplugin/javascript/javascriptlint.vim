" javascriptlint.vim -- javascriptlint
" @Author:      Vincent Wang (mailto:linsong.qizi@gmail.com)
" @Website:     vincent-wang.blogspots.com
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-04-28.
" @Last Change: 19-Mai-2005.
" @Revision:    0.0

if &cp || exists("loaded_javascriptlint")
    finish
endif
let loaded_javascriptlint = 1

set makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -conf\ '$HOME/jsl.conf'\ -process\ %
set errorformat=%f(%l):\ %m



