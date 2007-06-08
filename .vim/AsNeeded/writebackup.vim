" writebackup.vim: Write backups of current file with date file extension in the
" same directory. 
"
" DESCRIPTION:
"   This is the poor man's revision control system, a primitive alternative to
"   CVS, RCS, Subversion, etc., which works with no additional software and
"   almost any file system. 
"   The ':WriteBackup' command writes subsequent backups of the current file
"   with a current date file extension (format '.YYYYMMDD[a-z]') in the same
"   directory as the file itself. The first backup of a day has letter 'a'
"   appended, the next 'b', and so on. (Which means that a file can be backed up
"   up to 26 times on any given day.) 
"
" USAGE:
"   :WriteBackup
"
" INSTALLATION:
"   Put the script into your user or system VIM plugin directory (e.g.
"   ~/.vim/plugin). 
"
" DEPENDENCIES:
"   - Requires VIM 6.2. 
"
" CONFIGURATION:
"   In case you already have other custom VIM commands starting with W, you can
"   define a shorter command alias ':W' in your .vimrc to save some keystrokes.
"   I like the parallelism between ':w' for a normal write and ':W' for a backup
"   write. 
"	command W :WriteBackup
"
" Copyright: (C) 2007 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" REVISION	DATE		REMARKS 
"   1.00.004	07-Mar-2007	Added documentation. 
"	0.03	06-Dec-2006	Factored out WriteBackup_GetBackupFilename() to
"				use in :WriteBackupOfSavedOriginal. 
"	0.02	14-May-2004	Avoid that the written file becomes the
"				alternate file (via set cpo-=A)
"	0.01	15-Nov-2002	file creation

" Avoid installing twice or when in compatible mode
if exists("g:loaded_writebackup") || (v:version < 602)
    finish
endif
let g:loaded_writebackup = 1

function! WriteBackup_GetBackupFilename()
    let l:date = strftime( "%Y%m%d" )
    let l:nr = 'a'
    while( l:nr <= 'z' )
	let l:backupfilename = expand("%").'.'.l:date.l:nr
	if( filereadable( l:backupfilename ) )
	    " Current backup letter already exists, try next one. 
	    " Vim script cannot increment characters; so convert to number for increment. 
	    let l:nr = nr2char( char2nr(l:nr) + 1 )
	    continue
	endif
	" Found unused backup letter. 
	return l:backupfilename
    endwhile

    " All backup letters a-z are already used; report error. 
    throw 'WriteBackup: Ran out of backup file names'
endfunction

function! s:WriteBackup()
    try
	let l:saved_cpo = &cpo
	set cpo-=A
	execute 'write ' . WriteBackup_GetBackupFilename()
    catch /^WriteBackup:/
	" All backup letters a-z are already used; report error. 
	echohl Error
	echomsg "Ran out of backup file names"
	echohl None
    catch /^Vim\%((\a\+)\)\=:E/
	echohl Error
	echomsg substitute( v:exception, '^Vim\%((\a\+)\)\=:', '', '' )
	echohl None
    finally
	let &cpo = l:saved_cpo
    endtry
endfunction

command! WriteBackup :call <SID>WriteBackup()

