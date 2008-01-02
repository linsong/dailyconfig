" writebackupVersionControl.vim: Version control functions (diff, restore) for
" writebackup.vim backups with date file extension (format '.YYYYMMDD[a-z]'). 
"
" DESCRIPTION:
"   This script enhances the primitive file backup mechanism provided by
"   writebackup.vim with some functions of real revision control systems like
"   CVS, RCS or Subversion - without additional software. 
"   Via VIM commands, you can list all backup versions that exist for the
"   current file, check whether you have a current backup, backup the saved
"   version of the buffer even after you've made unsaved changes in the buffer
"   (which is useful for after-the-fact backups). 
"   Within VIM, you can create a diff with the previous version, restore the
"   current file from its predecessor or any other backed-up version. 
"
" USAGE:
"   :WriteBackupDiffWithPred
"	Performs a diff of the current file (which may be the current version or
"	an older backup) with the previous version. The diff is done inside VIM,
"	with a new diffsplit being opened. 
"
"   :WriteBackupListVersions
"	List all backup versions that exist for the current file. If the file
"	isn't the current version, it is marked in the version list. If the file
"	is the current version, the time that has passed since the last backup
"	is printed, too. 
"
"   :WriteBackupIsBackedUp
"	Checks whether the latest backup is identical to the (saved version of
"	the) current file (which must be the latest version). 
"
"   :WriteBackupRestoreFromPred
"	Overwrites the current file (which must be the latest version) with its
"	latest backup. 
"
"   :WriteBackupRestoreThisBackup
"	Restores the current file as the latest version, which will be
"	overwritten. 
"
"   :WriteBackupOfSavedOriginal
"	Instead of backing up the current buffer, back up the saved version of
"	the buffer. This comes handy when you realize you need a backup only
"	after you've made changes to the buffer. 
"
" INSTALLATION:
"   Put the script into your user or system VIM plugin directory (e.g.
"   ~/.vim/plugin). 
"
" DEPENDENCIES:
"   - Requires VIM 7.0 or higher. 
"   - Requires writebackup.vim (vimscript #1828). 
"   - External commands 'diff', 'cp' (Unix), 'copy' (Windows). 
"
" CONFIGURATION:
"   For a permanent configuration, put the following commands into your vimrc
"   file (see :help vimrc). 
"						  *g:writebackup_DiffVertSplit*
"   To change the default diffsplit from vertical to horizontal, use: 
"	let g:writebackup_DiffVertSplit = 0
"
" Copyright: (C) 2007 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" REVISION	DATE		REMARKS 
"   1.20.009	30-Dec-2007	:WriteBackupListVersions and
"				:WriteBackupDiffWithPred claimed "no backups
"				exist" if option 'wildignore' hides the backup
"				files. Now temporarily resetting the option
"				before glob(). 
"   1.20.008	18-Sep-2007	ENH: Added support for writing backup files into
"				a different directory (either one static backup
"				dir or relative to the original file). 
"				Now requires writebackup.vim version 1.20 or
"				later. 
"   1.00.007	17-Sep-2007	Command :WriteBackupOfSavedOriginal now checks
"				that the file is an original one. 
"				Refactored s:WriteBackupOfSavedOriginal(): Moved
"				expand('%') out of the function; the original
"				file is now passed as an argument like it is for
"				all other functions. 
"				WriteBackup_GetBackupFilename() now takes a
"				originalFilespec argument, too. 
"				BF: :WriteBackupIsBackedUp doesn't deal
"				correctly with filenames that contain special ex
"				characters [%#!]. Now using system() instead of
"				'silent !' to avoid additional escaping. 
"   1.00.006	07-Mar-2007	Added documentation. 
"	0.05	06-Dec-2006	Factored out Copy() function. 
"				Implemented :WriteBackupOfSavedOriginal command. 
"	0.04	16-Nov-2006	BF: '%' and '#' must also be escaped for VIM. 
"	0.03	02-Nov-2006	ENH: Added user information that IsBackedUp()
"				compares with saved version, not modified
"				buffer. 
"				BF: In Restore() and IsBackedUp(), expand
"				filespecs to absolute paths to avoid problems
"				with CWD, especially on Windows systems with UNC
"				paths. 
"				BF: In DiffWithPred() and RestoreThisBackup(),
"				convert the filespec to VIM syntax. 
"	0.02	31-Oct-2006	Added WriteBackupListVersions. 
"				Added EchoElapsedTimeSinceVersion as an add-on
"				to WriteBackupListVersions. 
"				Added WriteBackupIsBackedUp. 
"				Added RestoreFromPred and RestoreThisBackup. 
"				Optimized away actual diff invocation in
"				IsBackedUp() for most cases. 
"				cases
"	0.01	30-Oct-2006	file creation

" Avoid installing twice or when in compatible mode
if exists('g:loaded_writebackupVersionControl') || (v:version < 700)
    finish
endif
if ! exists('g:loaded_writebackup')
    runtime plugin/writebackup.vim
endif
if ! exists('g:loaded_writebackup') || g:loaded_writebackup < 120
    echomsg 'writebackupVersionControl: You need a newer version of writebackup.vim plugin. '
    finish
endif
let g:loaded_writebackupVersionControl = 120



" Allow user to specify diffsplit of horiz. or vert.
if !exists('g:writebackup_DiffVertSplit')
    let g:writebackup_DiffVertSplit = 1  " Default to split for diff vertically. 
endif

let s:versionRegexp = '\.[12]\d\d\d\d\d\d\d[a-z]$'
let s:versionFileGlob = '.[12][0-9][0-9][0-9][0-9][0-9][0-9][0-9][a-z]'
let s:versionLength = 10 " 1 dot + 4 year + 2 month + 2 day + 1 letter

"- conversion functions -------------------------------------------------------
function! s:IsOriginalFile( filespec )
    return a:filespec !~? s:versionRegexp
endfunction

function! s:GetOriginalFilespec( filespec, isForDisplayingOnly )
"*******************************************************************************
"* PURPOSE:
"   The passed a:filespec may be any ordinary file, an original file that has
"   backups, or a backup file. In the last case, it is tried to determine the
"   original filespec. This is only guaranteed to work when backups are
"   created in the same directory as the original file. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec
"   a:isForDisplayingOnly   If true, returns an approximation of the original
"	file for use in a user message in case it cannot be resolved. If false,
"	return an empty string in that case. 
"* RETURN VALUES: 
"	original filespec, or empty string, or approximation
"*******************************************************************************
    if s:IsOriginalFile( a:filespec )
	return a:filespec
    else
	let l:adjustedBackupFilespec = strpart( a:filespec, 0, len( a:filespec ) - s:versionLength )

	if WriteBackup_GetBackupDir() == '.' && filereadable(l:adjustedBackupFilespec)
	    " If backups are created in the same directory, we can get the original
	    " file by stripping off the tailing file version. 
	    " A buffer-local backup directory configuration which only exists for
	    " the original file buffer, but not the backup file buffer may fool us
	    " here into believing that backups are created in the same directory, so
	    " we explicitly check that the original file exists there as well. 
	    return l:adjustedBackupFilespec
	else
	    " If backups are created in a different directory, the complete filespec
	    " of the original file can not be derived from the adjusted backup
	    " filespec, as WriteBackup_AdjustFilespecForBackupDir() (potentially) is
	    " a one-way transformation from multiple directories to one backup
	    " directory. 
	    "
	    " TODO: Look for original file candidates in all VIM buffers via bufname(). 
	    "
	    " When we fail, return an empty string to indicate that the original
	    " filespec could not be resolved. However, if the filespec is only
	    " needed for a user message, we can generate an approximation, which is
	    " better than nothing. 
	    if a:isForDisplayingOnly
		return '???/' . fnamemodify( l:adjustedBackupFilespec, ':t' )
	    else
		return ''
	    endif
	endif
    endif
endfunction

function! s:GetVersion( filespec )
    if ! s:IsOriginalFile( a:filespec )
	return strpart( a:filespec, len( a:filespec ) - s:versionLength + 1 )
    else
	return ''
    endif
endfunction

function! s:GetAdjustedBackupFilespec( filespec )
"*******************************************************************************
"* PURPOSE:
"   The adjustedBackupFilespec is an imaginary file in the backup directory. By
"   appending a backup version, a valid backup filespec is created. 
"   In case the backup is done in the same directory as the original file, the
"   adjustedBackupFilespec is equal to the original file. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec
"* RETURN VALUES: 
"   adjustedBackupFilespec; the backup directory may not yet exist when no
"   backups have yet been made. 
"*******************************************************************************
    if s:IsOriginalFile( a:filespec )
	return WriteBackup_AdjustFilespecForBackupDir( a:filespec, 1 )
    else
	return strpart( a:filespec, 0, len( a:filespec ) - s:versionLength )
    endif
endfunction

"------------------------------------------------------------------------------
function! s:VerifyIsOriginalFileAndHasPredecessor( filespec, notOriginalMessage )
"*******************************************************************************
"* PURPOSE:
"   Checks that a:filespec is not a backup file and that at least one backup for
"   this file exists. If not, an error message is echoed; in the first case,
"   the passed a:notOriginalMessage is used. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:filespec
"   a:notOriginalMessage
"* RETURN VALUES: 
"   empty string if verification failed; filespec of predecessor otherwise. 
"*******************************************************************************
    if ! s:IsOriginalFile( a:filespec )
	echohl Error
	echomsg a:notOriginalMessage
	echohl None
	return ''
    endif

    let l:predecessor = s:GetPredecessorForFile( a:filespec )
    if empty( l:predecessor )
	echohl Error
	echomsg "No predecessor found for file '" . a:filespec . "'."
	echohl None
	return ''
    endif

    return l:predecessor
endfunction

"------------------------------------------------------------------------------
function! s:GetAllBackupsForFile( adjustedBackupFilespec )
"*******************************************************************************
"* PURPOSE:
"   Retrieves a list of all filespecs of backup files for
"   a:adjustedBackupFilespec. 
"   The list is sorted from oldest to newest backup. The original filespec is
"   not part of the list. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:adjustedBackupFilespec	describes a file in the backup directory,
"   without a version
"* RETURN VALUES: 
"   sorted list of backup filespecs
"*******************************************************************************
    " glob() filters out file patterns defined in 'wildignore'. If someone wants
    " to ignore backup files for command-mode file name completion and puts the
    " backup file pattern into 'wildignore', this function will break. 
    " Thus, the 'wildignore' option is temporarily reset here. 
    if has('wildignore')
	let l:save_wildignore = &wildignore
	set wildignore=
    endif
    try
	" glob() will do the right thing and return an empty list if
	" a:adjustedBackupFilespec doesn't yet exist, because no backup has yet been
	" made. 
	let l:backupfiles = split( glob( a:adjustedBackupFilespec . s:versionFileGlob ), "\n" )

	" Although the glob should already be sorted alphabetically in ascending
	" order, we'd better be sure and sort the list on our own, too. 
	let l:backupfiles = sort( l:backupfiles )
"****D echo '**** backupfiles: ' . l:backupfiles
	return l:backupfiles
    finally
	if has('wildignore')
	    let &wildignore = l:save_wildignore
	endif
    endtry

endfunction

function! s:RemoveNewerBackupsFrom( backupfiles, currentVersion )
"*******************************************************************************
"* PURPOSE:
"   Removes files from the passed list that are newer or equal to a:currentVersion. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   Truncates a:backupfiles so that any file version contained is older than a:currentVersion. 
"* INPUTS:
"   a:backupfiles: sorted list of filespecs. 
"   a:currentVersion: version number used as the exclusion criterium. 
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:fileCnt = 0
    while l:fileCnt < len( a:backupfiles )
	if s:GetVersion( a:backupfiles[ l:fileCnt ] ) >= a:currentVersion 
"****D echo '**** removing indexes ' . l:fileCnt . ' to ' . (len( a:backupfiles ) - 1)
	    call remove( a:backupfiles, l:fileCnt, len( a:backupfiles ) - 1 )
"****D call confirm('debug')
	    break
	endif
	let l:fileCnt += 1
    endwhile
endfunction

function! s:GetPredecessorForFile( filespec )
"*******************************************************************************
"* PURPOSE:
"   Gets the filespec of the predecessor of the passed filespec, regardless of
"   whether the passed filespec is the current file (without a version
"   extension), or a versioned backup. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:filespec
"* RETURN VALUES: 
"   filespec to the predecessor version. 
"*******************************************************************************
    let l:backupfiles = s:GetAllBackupsForFile( s:GetAdjustedBackupFilespec(a:filespec) )
    if ! s:IsOriginalFile( a:filespec )
	call s:RemoveNewerBackupsFrom( l:backupfiles, s:GetVersion(a:filespec) )
    endif

    if empty( l:backupfiles )
	return ''
    else
	let l:predecessor = l:backupfiles[ len( l:backupfiles ) - 1 ]
	return l:predecessor
    endif
endfunction

function! s:DiffWithPred( filespec )
"*******************************************************************************
"* PURPOSE:
"   Creates a diff with the predecessor of the passed a:filespec. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:predecessor = s:GetPredecessorForFile( a:filespec )
    if empty( l:predecessor )
	echohl Error
	echomsg "No predecessor found for file '" . a:filespec . "'."
	echohl None
    else
"****D echo '**** predecessor is ' . l:predecessor
	if g:writebackup_DiffVertSplit == 1
	    let l:splittype=':vert diffsplit '
	else
	    let l:splittype=':diffsplit '
	endif
	execute l:splittype . escape( tr( l:predecessor, '\', '/'), ' \%#' )
    endif
endfunction

function! s:DualDigit( number )
"*******************************************************************************
"* PURPOSE:
"   Formats the passed number as a dual-digit string. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"	? Explanation of the value returned.
"*******************************************************************************
    let l:digits = a:number + ''
    while len( l:digits ) < 2
	let l:digits = '0' . l:digits
    endwhile
    return strpart( l:digits, 0, 2 )
endfunction

function! s:EchoElapsedTimeSinceVersion( backupFile )
"*******************************************************************************
"* PURPOSE:
"   Informs the user about the elapsed time since the passed a:backupFile has
"   been modified. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:timeElapsed = localtime() - getftime( a:backupFile )
    let l:secondsElapsed = l:timeElapsed % 60
    let l:minutesElapsed = (l:timeElapsed / 60) % 60
    let l:hoursElapsed = (l:timeElapsed / 3600) % 24
    let l:daysElapsed = (l:timeElapsed / (3600 * 24))
    let l:message = 'The last backup was done '
    if l:daysElapsed > 0
	let l:message .= l:daysElapsed . ' days, '
    endif
    let l:message .= s:DualDigit(l:hoursElapsed) . ':' . s:DualDigit(l:minutesElapsed) . ':' . s:DualDigit(l:secondsElapsed) . ' ago.'

    echomsg l:message
endfunction

function! s:ListVersions( filespec )
"*******************************************************************************
"* PURPOSE:
"   Shows the user a list of all available versions for a:filespec. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:originalFilespec = s:GetOriginalFilespec( a:filespec, 1 )
    let l:currentVersion = s:GetVersion( a:filespec )
    let l:backupfiles = s:GetAllBackupsForFile( s:GetAdjustedBackupFilespec(a:filespec) )
    if empty( l:backupfiles )
	echomsg "No backups exist for file '" . l:originalFilespec . "'. "
	return
    endif

    let l:versionMessageHeader = "These backups exist for file '" . l:originalFilespec . "'"
    let l:versionMessageHeader .= ( empty(l:currentVersion) ? ': ' : ' (current version is marked >x<): ')
    echomsg l:versionMessageHeader

    let l:versionMessage = ''
    let l:backupVersion = ''
    for l:backupfile in l:backupfiles
	let l:previousVersion = l:backupVersion
	let l:backupVersion = s:GetVersion( l:backupfile )
	if strpart( l:backupVersion, 0, len(l:backupVersion) - 1 ) == strpart( l:previousVersion, 0, len(l:previousVersion) - 1 )
	    let l:versionMessageAddition = strpart( l:backupVersion, len(l:backupVersion) - 1 )
	    if l:backupVersion == l:currentVersion
		let l:versionMessageAddition = '>' . l:versionMessageAddition . '<'
	    endif
	    let l:versionMessage .= l:versionMessageAddition
	else
	    echomsg l:versionMessage 
	    let l:versionMessage = l:backupVersion
	    if l:backupVersion == l:currentVersion
		let l:versionMessage= strpart( l:versionMessage, 0, len(l:versionMessage) - 1 ). '>' . strpart( l:versionMessage, len(l:versionMessage) - 1 ) . '<'
	    endif
	endif
    endfor
    echomsg l:versionMessage

    if empty( l:currentVersion )
	let l:lastBackupFile = l:backupfiles[ len( l:backupfiles ) - 1 ]
	call s:EchoElapsedTimeSinceVersion( l:lastBackupFile )
    endif
endfunction

function! s:IsBackedUp( filespec )
"*******************************************************************************
"* PURPOSE:
"   Informs the user whether there exists a backup for the passed a:filespec file. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:predecessor = s:VerifyIsOriginalFileAndHasPredecessor( a:filespec, 'You can only check the backup status of the original file, not of backups!' )
    if empty( l:predecessor )
	return
    endif

    " As we compare the predecessor with the saved original file, not the actual
    " buffer contents (and this is what the user typically wants; checking
    " whether it is safe to write this buffer because an update exists), we add
    " a hint to the user message if the buffer is indeed modified. 
    let l:savedMsg = (&l:modified ? 'saved ' : '') 

    " Optimization: First compare the file sizes, as this is much faster than
    " performing an actual diff; we're not interested in the differences,
    " anyway, only if there *are* any!
    if getfsize( l:predecessor ) != getfsize( a:filespec )
	echohl WarningMsg
	echomsg "The current " . l:savedMsg . "version of '" . a:filespec . "' is different from the latest backup version '" . s:GetVersion( l:predecessor ) . "'. "
	echohl None
	return
    endif

    " Expand filespecs to absolute paths to avoid problems with CWD, especially
    " on Windows systems with UNC paths. 
    let l:predecessorFilespec = fnamemodify( l:predecessor, ':p' )
    let l:originalFilespec = fnamemodify( a:filespec, ':p' )

    " Note: We could save the effort of outputting the diff output to the
    " console if that didn't introduce platform-dependent code (NUL vs.
    " /dev/null) and meddling with the 'shellredir' setting. 
    let l:diffCmd = 'diff "' . l:predecessorFilespec . '" "' . l:originalFilespec . '"'
    call system( l:diffCmd )
"****D echo '**** diff return code=' . v:shell_error

    if v:shell_error == 0
	echomsg "The current " . l:savedMsg . "version of '" . a:filespec . "' is identical with the latest backup version '" . s:GetVersion( l:predecessor ) . "'. "
    elseif v:shell_error == 1
	echohl WarningMsg
	echomsg "The current " . l:savedMsg . "version of '" . a:filespec . "' is different from the latest backup version '" . s:GetVersion( l:predecessor ) . "'. "
	echohl None
    elseif v:shell_error >= 2
	echohl Error
	echomsg "Encountered problems with the 'diff' tool. Unable to compare with latest backup. "
	echohl None
    endif
endfunction

function! s:Copy( source, target )
"*******************************************************************************
"* PURPOSE:
"   Copies a:source to a:target. If a:target exists, it is overwritten. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   Creates / modifies a:target on the file system. 
"* INPUTS:
"   a:source filespec
"   a:target filespec
"* RETURN VALUES: 
"   none
"   throws 'WriteBackupVersionControl: Unsupported operating system type.'
"   throws copy command output if shell copy command failed
"*******************************************************************************
    " Expand filespecs to absolute paths to avoid problems with CWD, especially
    " on Windows systems with UNC paths. 
    let l:sourceFilespec = fnamemodify( a:source, ':p' )
    let l:targetFilespec = fnamemodify( a:target, ':p' )

    if has('win32')
	let l:copyCmd = 'copy /Y "' . l:sourceFilespec . '" "' . l:targetFilespec . '"'
    elseif has('unix')
	let l:copyCmd = 'cp "' . l:sourceFilespec . '" "' . l:targetFilespec . '"'
    else
	throw 'WriteBackupVersionControl: Unsupported operating system type.'
    endif

    let l:cmdOutput = system( l:copyCmd )
    if v:shell_error != 0
	throw l:cmdOutput
    endif
endfunction

function! s:Restore( source, target, confirmationMessage )
"*******************************************************************************
"* PURPOSE:
"   Restores a:source over an existing a:target. The user is asked to confirm
"   this destructive operation, using the passed a:confirmationMessage. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   Modifies a:target on the file system. 
"* INPUTS:
"   a:source filespec
"   a:target filespec
"   a:confirmationMessage
"* RETURN VALUES: 
"   boolean indicating whether the file has actually been restored. 
"*******************************************************************************
    let l:response = confirm( a:confirmationMessage, "&No\n&Yes", 1, 'Question' )
    if l:response != 2
	echomsg 'Restore canceled. '
	return 0
    endif

    " We could restore using only VIM functionality:
    "	edit! a:target
    " 	normal ggdG
    " 	0read a:source
    " 	write
    " But that would make the target's modification date different from the one
    " of the source, which would fool superficial synchronization tools. 
    " In addition, there's the (small) risk that VIM autocmds or settings like
    " 'fileencoding' or 'fileformat' are now different from when the backup was
    " written, and may thus lead to conversion errors or different file
    " contents. 
    " Thus, we invoke an external command to create a perfect copy.
    " Unfortunately, this introduces platform-specific code. 
    try
	call s:Copy( a:source, a:target )
    catch
	echohl Error
	echomsg 'Failed to restore file: ' . v:exception
	echohl None
	return 0
    endtry
    return 1
endfunction

function! s:RestoreFromPred( originalFilespec )
"*******************************************************************************
"* PURPOSE:
"   Restores the passed original file with its latest backup. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:predecessor = s:VerifyIsOriginalFileAndHasPredecessor( a:originalFilespec, 'You can only restore the original file, not a backup!' )
    if empty( l:predecessor )
	return
    endif

    if s:Restore( l:predecessor, a:originalFilespec, "Really override this file with backup '" . s:GetVersion( l:predecessor ) . "'?" )
	edit!
    endif
endfunction

function! s:RestoreThisBackup( filespec )
"*******************************************************************************
"* PURPOSE:
"   Restores the passed file as the original file. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"   none
"*******************************************************************************
    let l:currentVersion = s:GetVersion( a:filespec )
    if empty( l:currentVersion )
	echohl Error
	echomsg 'You can only restore backup files!'
	echohl None
	return
    endif

    let l:originalFilespec = s:GetOriginalFilespec( a:filespec, 0 )
    if empty( l:originalFilespec )
	echohl Error
	echomsg 'Unable to determine the location of the original file. '
	" TODO: 'Unable to determine the location of the original file; open it in another buffer. '
	echohl None
	return
    endif

    if s:Restore( a:filespec, l:originalFilespec, "Really override '" . l:originalFilespec . "' with this backup '" . l:currentVersion . "'?" )
	execute 'edit! ' . escape( tr( l:originalFilespec, '\', '/'), ' \%#' )
    endif
endfunction

function! s:WriteBackupOfSavedOriginal( filespec )
"*******************************************************************************
"* PURPOSE:
"   Instead of backing up the current buffer, back up the saved version of the
"   buffer. 
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"	? Explanation of each argument that isn't obvious.
"* RETURN VALUES: 
"   none
"*******************************************************************************
    if ! s:IsOriginalFile( a:filespec )
	echohl Error
	echomsg 'You can only backup the latest file version, not a backup file itself!'
	echohl None
	return
    endif

    try
	let l:backupfilename = WriteBackup_GetBackupFilename( a:filespec )
	call s:Copy(  a:filespec, l:backupfilename )
	echomsg '"' . l:backupfilename . '" written'
    catch /^WriteBackup:/
	" All backup letters a-z are already used; report error. 
	echohl Error
	echomsg "Ran out of backup file names"
	echohl None
    catch
	echohl Error
	echomsg 'Failed to backup file: ' . v:exception
	echohl None
    endtry
endfunction

"- commands -------------------------------------------------------------------
command! WriteBackupDiffWithPred	:call <SID>DiffWithPred(expand('%'))
command! WriteBackupListVersions	:call <SID>ListVersions(expand('%'))
command! WriteBackupIsBackedUp		:call <SID>IsBackedUp(expand('%'))
command! WriteBackupRestoreFromPred	:call <SID>RestoreFromPred(expand('%'))
command! WriteBackupRestoreThisBackup	:call <SID>RestoreThisBackup(expand('%'))
"command! WriteBackupDeleteLastBackup
command! WriteBackupOfSavedOriginal	:call <SID>WriteBackupOfSavedOriginal(expand('%'))

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
