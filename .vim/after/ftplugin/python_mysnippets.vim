" python_mysnippets.vim
" @Author:      <+NAME+> (mailto:<+EMAIL+>)
" @Website:     <+WWW+>
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-05-08.
" @Last Change: 19-Mai-2005.
" @Revision:    0.0

if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet pdb import pdb, readline; pdb.set_trace();"
exec "Snippet rpdb import rpdb2; rpdb2.start_embedded_debugger('hello')"
exec "Snippet log import logging;
\<CR>logging.critical(\"".st.et."\")"

exec "Snippet manhole # set up  manhole service for debug purpose
\<CR># !!! ATTENTION: NEVER USE IT ON LIVESITE !!!
\<CR>from twisted.internet import reactor
\<CR>from twisted.manhole import telnet
\<CR>print 'Creating shell server instance'
\<CR>factory = telnet.ShellFactory()
\<CR>port = 8888
\<CR>reactor.listenTCP(port, factory)
\<CR>factory.namespace['".st.et."'] = 'hello world'
\<CR>factory.username = 'vincent'
\<CR>factory.password = 'foo'
\<CR>print 'Listening on port %d' % port"

exec "Snippet ipy #############  Embeded IPython #############
\<CR>try:
\<CR>     __IPYTHON__
\<CR>except NameError:
\<CR>     from IPython.Shell import IPShellEmbed
\<CR>     ipshell = IPShellEmbed()
\<CR>     # Now ipshell() will open IPython anywhere in the code
\<CR>else:
\<CR>     # Define a dummy ipshell() so the same code doesn’t crash inside an
\<CR>     # interactive IPython
\<CR>     def ipshell(): pass
\<CR>
\<CR>ipshell('***Hit Ctrl-D to exit interpreter and continue program.')
\<CR>#############       END        #############"

exec "Snippet header #! /usr/bin/env python
\<CR># -*- coding: utf8 -*- 
\<CR>".st.et
