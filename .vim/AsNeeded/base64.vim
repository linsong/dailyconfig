" base64.vim
" version 1.1
" dan sandler - http://dsandler.org/soft/
"
" handy commands for perfoming b64 transformations on ranges of text or on
" files.
"
" requires: an installation of python (the python executable must be somewhere
" in your PATH).
"
" works in windows and unix; ought to work on macosx.
"
" Commands:
"   Base64Decode, Base64Encode -- work on ranges
"   Base64DecodeFile, Base64EncodeFile -- read a file, transform contents,
"     inset results into buffer.
"
" Changelog:
"   1.1.0 [2004-Apr-5] Added proper support for binary streams.
"   1.0.0              First version.
" ----------------------------------------------------------------------

function! Base64Decode() range
	execute a:firstline . ',' . a:lastline . '!python -u -c "import base64,sys;base64.decode(sys.stdin,sys.stdout)"'
endfunction
function! Base64Encode() range
	execute a:firstline . ',' . a:lastline . '!python -u -c "import base64,sys;base64.encode(sys.stdin,sys.stdout)"'
endfunction
command! -range -nargs=0 Base64Decode <line1>,<line2>call Base64Decode()
command! -range -nargs=0 Base64Encode <line1>,<line2>call Base64Encode()
function! Base64DecodeFile(filename) 
	execute 'new'
	execute '.!python -u -c "import base64,sys;sys.stdout.write(base64.decodestring(open(sys.argv[1],\"rb\").read()))" ' .  a:filename
	execute 'file ' . a:filename . '.decoded'
endfunction
function! Base64EncodeFile(filename) 
	execute 'new'
	execute '.!python -u -c "import base64,sys;sys.stdout.write(base64.encodestring(open(sys.argv[1],\"rb\").read()))" ' .  a:filename
	execute 'file ' . a:filename . '.base64'
endfunction
command! -range -nargs=1 -complete=file Base64DecodeFile call Base64DecodeFile(<f-args>)
command! -range -nargs=1 -complete=file Base64EncodeFile call Base64EncodeFile(<f-args>)

