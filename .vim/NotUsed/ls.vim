" FileManager for VIM (v1.1) - by Michael Sharpe (feline@irendi.com)
" Released under the terms of the GNU Public License version 2
" depends on functions.vim for FindOrCreateBuffer()
"
" Global Commands
" ---------------
" LS - Enters "DirList" ls -aF mode (e.g :LS or :LS /tmp)
" LSL - Enters "DirList" ls -alF mode (e.g :LSL or :LSL /tmp)
"
" Commands in "DirList" mode
" --------------------------
" Tag - tags a range of lines (e.g. 'a,'s Tag in the DirList buffer)
"
" Macros in "DirList" mode
" ------------------------
" T - tag a line
" RM - remove all files/dirs which are tagged
" ED - EDit all files/dirs which are tagged
" CO - COmpresses tagged files
" UN - UNcompresses tagged files
" AR - ARchive tagged directories using tar and gzip
" EX - EXtract from tagged archive using gtar
" CP - copy each tagged file
" MV - move each tagged file
" LNS - symlink a file
" LNH - hard link a file
" dMV - move tagged files to a directory
" dCP - copy tagged files to a directory
" MKD - make a new directory
" S - which between long and short listings
" [Enter] - selects the current line (traverses a directory or edits a file
"

let g:DirListHighlightTags = 1
let g:DirListTrashDir = '/tmp'
let g:DirListAlwaysSave = 1
let g:DirListUseMVforRM = 1
let g:DirListRMCmd = '/bin/rm -rf'
let g:DirListGZIPCmd = 'gzip'
let g:DirListGUNZIPCmd = 'gunzip'
let g:DirListTARCmd = 'tar'
let g:DirListUseAllArg = 1
let g:DirListMVCmd = '/bin/mv -f'
let g:DirListCPCmd = '/bin/cp -f'
let g:DirListLNCmd = '/bin/ln -f'
let g:DirListMKDIRCmd = '/bin/mkdir -p'

function! GlobPath(path, addTrailingSlash)
   execute "cd " . a:path
   let cpath = getcwd()
   execute "cd -"
   if a:addTrailingSlash
      let cpath = substitute(cpath, "[^/]$", "\\0\/", "")
   endif
   return cpath
endfunction

" Function : FindOrCreateBuffer (PRIVATE)
" Purpose  : searches the buffer list (:ls) for the specified filename. If
"            found, checks the window list for the buffer. If the buffer is in
"            an already open window, it switches to the window. If the buffer
"            was not in a window, it switches to that buffer. If the buffer did
"            not exist, it creates it.
" Args     : filename (IN) -- the name of the file
"            doSplit (IN) -- indicates whether the window should be split
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com)
function! FindOrCreateBuffer(filename, doSplit)
  " Check to see if the buffer is already open before re-opening it.
  let bufName = bufname(a:filename)
  if (bufName == "")
     " Buffer did not exist....create it
     if (a:doSplit != 0)
        execute ":split " . a:filename
     else
        execute ":e " . a:filename
     endif
  else
     " Buffer was already open......check to see if it is in a window
     let bufWindow = bufwinnr(a:filename)
     if (bufWindow == -1)
        if (a:doSplit != 0)
           execute ":sbuffer " . a:filename
        else
           execute ":buffer " . a:filename
        endif
     else
        " search the windows for the target window
        if bufWindow != winnr()
           " only search if the current window does not contain the buffer
           execute "normal \<C-W>b"
           let winNum = winnr()
           while (winNum != bufWindow && winNum > 0)
              execute "normal \<C-W>k"
              let winNum = winNum - 1
           endwhile
           if (0 == winNum)
              " something wierd happened...open the buffer
              if (a:doSplit != 0)
                 execute ":split " . a:filename
              else
                 execute ":e " . a:filename
              endif
           endif
        endif
     endif
  endif
endfunction


function! DirList(useAllArg, dirNameArg)
    let report = &report
    set report=9999
    
    if a:dirNameArg == ""
       let dirName = getcwd()
    elseif match(a:dirNameArg, "^\/") == -1
       " relative path
       let dirName = getcwd()."/". a:dirNameArg
    else
       " absolute path
       let dirName = a:dirNameArg
    endif
    let dirName = GlobPath(dirName, 1)
 
    let title="MLWS"
    let buffername = g:DirListTrashDir . '/directory-listing-'.title

    call FindOrCreateBuffer(buffername, 1)

    " remove everyting in the buffer
    normal 1G
    normal dG

    let useAllArg = a:useAllArg
    if useAllArg == -1
       "use the last value 
       let useAllArg = g:DirListUseAllArg
    endif

    if useAllArg == 1
       let lsCmd = '/bin/ls -alF ' . dirName
    else
       let lsCmd = '/bin/ls -lF ' . dirName
    endif
    let g:DirListUseAllArg = useAllArg
 
    0 put ='Output of command - `' . lsCmd . '`'
    1 put ='Valid Commands: [Enter], T,S,ED,RM,CO,UN,AR,EX,CP,MV,LNS,LNH,dMV,dCP,MKD'
    2 put ='Directory is ' . dirName
    3 put ='------------------------------------------------------------------------------'
    if useAllArg == 0
       " get the . and .. entries
       let slsCmd = '/bin/ls -alF ' . dirName . '| head -3'
       4 put = system(slsCmd)
       7
    endif
    put = system(lsCmd)
    
    g/^total [0-9]*$/d
    g/^$/d
    5,$ s/^/  /ge
    
    if g:DirListAlwaysSave 
       w!
    else
       set nomod
    endif

    let &report=report
    normal 1G
    normal 5G
endfunction

function! DirListCleanup()
   let ix = 1
   while ix <= bufnr("$")
      if match(bufname(ix), 'directory-listing-') >= 0
         exe 'bd '.ix
      endif
      let ix = ix + 1
   endwhile
endfunction

function! DirListFilenameFromDirLine(dirLine)
   let name = substitute(a:dirLine, ".*[0-9] ", "", "")
   " the following is not entirely accurate. Should check file type first
   let name = substitute(name, "[*/=@|]$", "", "")
   return name
endfunction

function! DirListEditFileLine(lineNum)
   if a:lineNum > 4
      let line = getline(a:lineNum) 
      let currDirList = substitute(getline(3), "Directory is ", "", "")
      let currName = DirListFilenameFromDirLine(line)


      let isDir = match(line, "^[% ] d")
      if isDir >= 0
         if currName != "."
            let dname = GlobPath(currDirList . currName, 1)
         else
            let dname = currDirList
         endif
            call DirList(-1, dname)
      else
         if currDirList != getcwd()
            let fname = currDirList . currName
         else
            let fname = currName
         endif
         bunload!
         exe 'edit! ' . fname
      endif
   endif
endfunction

function! DirListTagLine(lineNum) range 
   if a:lineNum == -1
      " we know we have a range here....simple for the start of the range to be
      " the first line after the . and .. entries...this simulates a -range=7,$
      if a:firstline < 7
         let firstLine = 7
      else 
         let firstLine = a:firstline
      endif
      if firstLine > 6 && a:lastline >= firstLine
         let i = a:firstline
         while i <= a:lastline
            call DirListTagLine(i)
            let i = i + 1
         endwhile
      endif
   else
      " do not allow header, . and .. to be tagged
      if a:lineNum > 6
	 let line = getline(a:lineNum)
	 let isTagged = match(line, "^% ")
         if isTagged >= 0
            let line = substitute(line, "^%", " ", "")
         else
            let line = substitute(line, "^ ", "%", "")
         endif
         call setline(a:lineNum, line)
      endif
   endif
endfunction

function! DirListSwitchView()
   let currDirList = substitute(getline(3), "Directory is ", "", "")
   if g:DirListUseAllArg
      call DirList(0, currDirList)
   else
      call DirList(1, currDirList)
   endif
endfunction

function! DirListDoEDIT(fileList, dname)
   let cmd = 'edit! ' . a:fileList
   let cmd = substitute(cmd, "@@", "| edit! ", "g")
   bunload!
   execute cmd 
endfunction

function! DirListDoRM(fname, dname)
   if g:DirListUseMVforRM
      echo g:DirListMVCmd . ' ' . a:fname . ' ' . g:DirListTrashDir
      call system(g:DirListMVCmd . ' ' . a:fname . ' ' . g:DirListTrashDir)
   else
      echo system(g:DirListRMCmd . ' ' . a:fname)
      call system(g:DirListRMCmd . ' ' . a:fname)
   endif
endfunction

function! DirListDoUnCompress(fname, dname)
   execute ':cd ' . a:dname
   " Only uncompress it if it is compressed
   let isGzip = match(a:fname, "\.gz$")
   let isCompress = match(a:fname, "\.Z$")
   if isGzip >= 0 || isCompress >= 0
      echo g:DirListGUNZIPCmd . ' ' . a:fname
      call system(g:DirListGUNZIPCmd . ' ' . a:fname)
   endif
   execute ':cd -'
endfunction

function! DirListDoCompress(fname, dname)
   execute ':cd ' . a:dname
   " Only compress it if it is not compressed
   let isGzip = match(a:fname, "\.gz$")
   let isCompress = match(a:fname, "\.Z$")
   if isGzip >= -1 && isCompress >= -1
      echo g:DirListGZIPCmd . ' ' . a:fname
      call system(g:DirListGZIPCmd . ' ' . a:fname)
   endif
   execute ':cd -'
endfunction

function! DirListDoTarDir(fname, dname)
   execute ':cd ' . a:dname
   if isdirectory(a:fname)
      let archiveName = fnamemodify(a:fname, ":t:r") . ".tar"
      echo g:DirListTARCmd . " -cf " . archiveName . " " . a:fname
      call system(g:DirListTARCmd . " -cf " . archiveName . " " . a:fname) 
      echo g:DirListGZIPCmd . " " . archiveName
      call system(g:DirListGZIPCmd . " " . archiveName)
   endif
   execute ':cd -'
endfunction

function! DirListDoUnTar(fname, dname)
   execute ':cd ' . a:dname
   " only tar if it is not a tar archive already
   let isTar = match(a:fname, "\.tar$")
   let isGZTar = match(a:fname, "\.tar\.gz$")
   let isZTar = match(a:fname, "\.tar\.Z$")
   let isTGZTar = match(a:fname, "\.tgz$")
   if isTar >= 0
      echo g:DirListTARCmd . " -xf " . a:fname
      call system(g:DirListTARCmd . " -xf " . a:fname)
   elseif isGZTar >= 0 ||isZTar >= 0 || isTGZTar >= 0
      echo g:DirListTARCmd . " -zxf " . a:fname
      call system(g:DirListTARCmd . " -zxf " . a:fname)
   endif
   execute ':cd -'
endfunction

function! DirListDoCP(fname, dname)
   execute ':cd ' . a:dname
   let cpName = input("Copy " . a:fname . " to? :")
   if match(cpName, "^\\s*$") == -1
      call system(g:DirListCPCmd . ' ' . a:fname . ' ' . cpName)
   endif
   execute ':cd -'
endfunction

function! DirListDoMV(fname, dname)
   execute ':cd ' . a:dname
   let mvName = input("Move " . a:fname . " to? : ")
   if match(mvName, "^\\s*$") == -1
      call system(g:DirListMVCmd . ' ' . a:fname . ' ' . mvName)
   endif
   execute ':cd -'
endfunction

function! DirListDoLNS(fname, dname)
   execute ':cd ' . a:dname
   let lnsName = input("Link (soft) " . a:fname . " to? : ")
   if match(lnsName, "^\\s*$") == -1
      call system(g:DirListLNCmd . ' -s ' . a:fname . ' ' . lnsName)
   endif
   execute ':cd -'
endfunction

function! DirListDoLNH(fname, dname)
   execute ':cd ' . a:dname
   let lnhName = input("Link (hard) " . a:fname . " to? :")
   if match(lnhName, "^\\s*$") == -1
      call system(g:DirListLNCmd . ' ' . a:fname . ' ' . lnhName)
   endif
   execute ':cd -'
endfunction

function! DirListDoMV_ALL(fnames, dname)
   execute ':cd ' . a:dname
   let destDir = input("Destination Directory? : ")
   " check the directory is not empty
   if match(destDir, "^\\s*$") == -1
      if isdirectory(destDir)
         call system(g:DirListMVCmd . ' ' . a:fnames . ' ' . destDir)
      else
         echo "Directory " . destDir . " does not exist!"
      endif
   endif
   execute ':cd -'
endfunction

function! DirListDoCP_ALL(fnames, dname)
   execute ':cd ' . a:dname
   let destDir = input("Destination Directory? : ")
   " check the directory is not empty
   if match(destDir, "^\\s*$") == -1
      if isdirectory(destDir)
         call system(g:DirListCPCmd . ' ' . a:fnames . ' ' . destDir)
      else
         echo "Directory " . destDir . " does not exist!"
      endif
   endif
   execute ':cd -'
endfunction

function! DirListMakeDirectory()
   let currDir = substitute(getline(3), "Directory is ", "", "")
   execute ':cd ' . currDir
   let newDir = input("Directory to create? : ")
   if match(newDir, "^\\s*$") == -1
      call system(g:DirListMKDIRCmd . " " . newDir)
   endif
   execute ':cd -'
   call DirList(-1, currDir)
endfunction

function! DirListIterateTaggedFiles(cb, update, fullname)
   let currDirList = substitute(getline(3), "Directory is ", "", "")
   let lastLine = line('$')
   let i = 5
   while i <= lastLine
      let line = getline(i)
      let isTagged = match(line, "^% ")
      if isTagged >= 0
         let fname = DirListFilenameFromDirLine(line) 
         if a:fullname
            let fname = currDirList . fname
         endif
         execute "call " . a:cb . '("' . fname . '","' . currDirList '")'
      endif
      let i = i + 1
   endwhile
   if a:update
      call DirList(-1, currDirList)
   endif
endfunction

function! DirListGetTaggedFiles(cb, reverse, separator, update, fullname)
   let currDirList = substitute(getline(3), "Directory is ", "", "")
   let lastLine = line('$')
   let i = 5
   let fileList = ""
   while i <= lastLine
      let line = getline(i)
      let isTagged = match(line, "^% ")
      if isTagged >= 0
         let fname = DirListFilenameFromDirLine(line) 
         if a:fullname
            let fname = currDirList . fname
         endif
         if a:reverse
            let fileList = fname . a:separator . fileList
         else
            let fileList = fileList . a:separator . fname
         endif
      endif
      let i = i + 1
   endwhile

   " strip redundant separators
   if a:reverse
      let fileList = substitute(fileList, a:separator . '$', "", "")
   else
      let fileList = substitute(fileList, '^' . a:separator, "", "")
   endif

   " Invoke the callback function
   execute "call " . a:cb . '("' . fileList . '","' . currDirList . '")'
   if a:update
      call DirList(-1, currDirList)
   endif
endfunction

function! DirListSyntax()
   if has("syntax")
      syntax clear
      syntax match LsExe    "^[% ] \S*x.*"
      syntax match LsDir    "^[% ] d.*"
      syntax match LsSln    "^[% ] l.* -> .*"
      syntax match LsFifo   "^[% ] p.*"
      syntax match LsSpl    "^[% ] [cb].*"
      syntax match LsSock   "^[% ] s.*"
      syntax match LsGzip   "^.*\.gz$"
      syntax match LsC      "^.*\.[cC]$"
      syntax match LsH      "^.*\.[hH]$"
      syntax match LsCPP    "^.*\.[cC][pP][pP]$"
      syntax match LsJPG    "^.*\.[jJ][pP][gG]$"
      syntax match LsGIF    "^.*\.[gG][iI][fF]$"
      syntax match LsVim    "^.*\.[vV][iI][mM]$"
      syntax match LsVimrc  "^.*\.vimrc$"
      syntax match LsMake   "^.*[mM]akefile$"
      syntax match LsTcshrc "^.*cshrc.*$"
      highlight link LsDir    PreProc 
      highlight link LsSln    Identifier
      highlight link LsFifo   Function
      highlight link LsSock   Comment
      highlight link LsSpl    Comment
      highlight link LsExe    Type
      highlight link LsGzip   Special
      highlight link LsC      String
      highlight link LsH      String
      highlight link LsCPP    String
      highlight link LsVim    String
      highlight link LsVimrc  String
      highlight link LsTcshrc String
      highlight link LsMake   ModeMsg
      highlight link LsJPG    Statement
      highlight link LsGIF    Statement

      " highlight tags
      if g:DirListHighlightTags
         syntax match LsTag    "^% .*$"
         highlight link lsTag  Error
      endif
   endif
endfunction

function! DirListEnterBuf()
   " map <enter> to edit a file, also dbl-click
   nmap <cr>          :call DirListEditFileLine(line("."))<cr>
   nmap <2-LeftMouse> :call DirListEditFileLine(line("."))<cr>
   nmap T             :call DirListTagLine(line("."))<cr>
   vmap T             :call DirListTagLine(-1)<cr>
   nmap S       :call DirListSwitchView()<cr>
   nmap ED      :call DirListGetTaggedFiles("DirListDoEDIT", 1, "@@", 0, 1)<cr>
   nmap RM      :call DirListGetTaggedFiles("DirListDoRM", 0, " ", 1, 1)<cr>
   nmap CO      :call DirListIterateTaggedFiles("DirListDoCompress", 1, 0)<cr>
   nmap UN      :call DirListIterateTaggedFiles("DirListDoUnCompress", 1, 0)<cr>
   nmap AR      :call DirListIterateTaggedFiles("DirListDoTarDir", 1, 0)<cr>
   nmap EX      :call DirListIterateTaggedFiles("DirListDoUnTar", 1, 0)<cr>
   nmap CP      :call DirListIterateTaggedFiles("DirListDoCP", 1, 0)<cr>
   nmap MV      :call DirListIterateTaggedFiles("DirListDoMV", 1, 0)<cr>
   nmap LNS     :call DirListIterateTaggedFiles("DirListDoLNS", 1, 0)<cr>
   nmap LNH     :call DirListIterateTaggedFiles("DirListDoLNH", 1, 0)<cr>
   nmap dMV     :call DirListGetTaggedFiles("DirListDoMV_ALL", 0, " ", 1, 0)<cr>
   nmap dCP     :call DirListGetTaggedFiles("DirListDoCP_ALL", 0, " ", 1, 0)<cr>
   nmap MKD     :call DirListMakeDirectory()<cr>
   command! -range=% Tag <line1>,<line2>call DirListTagLine(-1)
   call DirListSyntax()
endfunction

function! DirListLeaveBuf()
    unmap <cr>
    unmap <2-LeftMouse>
    unmap T
    unmap S
    unmap ED
    unmap RM
    unmap CO
    unmap UN
    unmap AR
    unmap EX
    unmap CP
    unmap MV
    unmap LNS
    unmap LNH
    unmap dMV
    unmap dCP
    unmap MKD
    delcommand Tag
    if g:DirListAlwaysSave == 0 && !filereadable(expand("%"))
       bd!
    endif    
endfunction

augroup DirListBuf
    autocmd!
    autocmd BufEnter directory-listing-* call DirListEnterBuf()
    autocmd BufLeave directory-listing-* call DirListLeaveBuf()
    autocmd VimLeavePre * call DirListCleanup()
aug END

command! -nargs=? LS :call DirList(0,<q-args>)
command! -nargs=? LSL :call DirList(1,<q-args>)
