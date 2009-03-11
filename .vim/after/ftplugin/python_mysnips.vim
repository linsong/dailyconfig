if !exists('g:loaded_snips') || exists('s:did_python_mysnips')
     finish
endif
let s:did_python_mysnips = 1
"let snippet_file = 'python_mysnips'
let snippet_filetype = 'python'

exec "Snipp pdb import pdb, readline; pdb.set_trace();"
exec "Snipp rpdb import rpdb2; rpdb2.start_embedded_debugger('hello')"
exec "Snipp log import logging;\nlogging.critical(${1})"

exec "Snipp manhole # set up  manhole service for debug purpose
\\n# !!! ATTENTION: NEVER USE IT ON LIVESITE !!!
\\nfrom twisted.internet import reactor
\\nfrom twisted.manhole import telnet
\\nprint 'Creating shell server instance'
\\nfactory = telnet.ShellFactory()
\\nport = 8888
\\nreactor.listenTCP(port, factory)
\\nfactory.namespace['${1}'] = 'hello world'
\\nfactory.username = 'vincent'
\\nfactory.password = 'foo'
\\nprint 'Listening on port %d' % port"

exec "Snipp ipy #############  Embeded IPython #############
\\ntry:
\\n     __IPYTHON__
\\nexcept NameError:
\\n     from IPython.Shell import IPShellEmbed
\\n     ipshell = IPShellEmbed()
\\n     # Now ipshell() will open IPython anywhere in the code
\\nelse:
\\n     # Define a dummy ipshell() so the same code doesn’t crash inside an
\\n     # interactive IPython
\\n     def ipshell(): pass
\\n
\\nipshell('***Hit Ctrl-D to exit interpreter and continue program.')
\\n#############       END        #############"

exec "Snipp header #! /usr/bin/env python
\\n# -*- coding: utf8 -*- 
\\n"
