"for check patch

"export Vcd_Patch()
"export Vcd_MakeDiff()
"export Vcd_ShowDiff()
"export Vcd_FoldFileName()

set patchexpr=Vcd_Patch()
function! Vcd_Patch()
    execute '!patch -R -o ' . v:fname_out . 
        \ ' ' . v:fname_in . ' < ' . v:fname_diff
endfunction

let s:patch_base=expand("~/.vim")
let s:patch_archive=s:patch_base . "/patch_archive.tmp"
let s:patch=s:patch_base . "/patch.tmp"

function! Vcd_MakePatchCmd_SVN(file_name, patch_file)
    let l:make_patch_cmd=
        \ ':!svn diff' . 
        \ a:file_name . 
        \ ' | grep -v "^\?" > ' .
        \ a:patch_file
    if a:file_name==""
        let l:make_patch_cmd=l:make_patch_cmd . 
            \ ';grep "^Index: " ' .
            \ a:patch_file
    endif
    return l:make_patch_cmd
endfunction

function! Vcd_MakePatchCmd_CVS(file_name, patch_file)
    let l:make_patch_cmd=
        \ ':!cvs diff -p ' . 
        \ a:file_name . 
        \ ' | grep -v "^\?" > ' .
        \ a:patch_file
    if a:file_name==""
        let l:make_patch_cmd=l:make_patch_cmd . 
            \ ';grep "^Index: " ' .
            \ a:patch_file
    endif
    return l:make_patch_cmd
endfunction

function! Vcd_MakePatch(paf, patch_target, patch_file_name)
    let     l:patch_sp="Index: " . a:patch_target
    silent execute 
        \ '!awk "BEGIN {make_patch_flag=0;skip_line=0}' . 
        \ '/^' . 
        \ escape(l:patch_sp, "/") . 
        \ '\$/{make_patch_flag=1;next}' . 
        \ '/^Index:/{if(make_patch_flag==1){exit}}' . 
        \ '{if((make_patch_flag==1)&&(skip_line>2))' . 
        \ '{print \$0}else {skip_line++}} " ' .
        \ a:paf  . 
        \ ' > ' .
        \ a:patch_file_name
endfunction

function! Vcd_ShowDiff()
    let     l:patch_target=strpart(getline("."), 7)
    if getftime(l:patch_target) == -1
        echo "Not such file"
        return
    endif
    call    Vcd_MakePatch(expand("%"), l:patch_target, s:patch)
    if getfsize(l:patch_target) == 0
        echo "Not patch"
    endif
    silent execute ":set columns=165"
    silent execute ":e " . l:patch_target
    silent execute ":vert diffpatch " . s:patch
endfunction

function! Vcd_IsCVS()
    let l:size = getfsize("CVS")
    if l:size == 0  "CVS is directory
        return 1
    else
        return 0
    endif
endfunction

function! Vcd_MakeDiff()
    let l:lang=$LANG
    let $LANG="C"
    if Vcd_IsCVS()
        execute Vcd_MakePatchCmd_CVS("", s:patch_archive)
    else
        execute Vcd_MakePatchCmd_SVN("", s:patch_archive)
    endif
    let $LANG=l:lang
    if getftime(s:patch_archive) == -1
        echo "Need " . s:patch_archive
        return
    endif
    silent execute ":e " . s:patch_archive
    call FoldPatch()
endfunction

function! FoldPatch()
    let l:last_line=line("$")
    let i = 1
    let l:fold_begin=0
    let l:fold_end=0
    while i <= l:last_line
        if getline(i) =~# "^Index: .*$"
            if l:fold_end != 0
                silent execute l:fold_begin + 1 . "," . l:fold_end . "fold"
                let l:fold_begin = 0
                let l:fold_end = 0
            endif
            let l:fold_begin=i
        elseif l:fold_begin != 0
            let l:fold_end=i
        endif
        let i = i + 1
    endwhile
    if l:fold_end != 0
    silent execute l:fold_begin + 1 . "," . l:fold_end . "fold"
    endif
endfunction

function! Vcd_FoldFileName()
    let i=line(".")
    if getline(i) !~# "^Index: .*$"
        return
    endif
    let l:last_line=line("$")
    while i <= l:last_line
        if foldclosed(i) != -1
            silent execute line(".") . "," . foldclosedend(i) . "fold"
            break
        endif
        let i = i + 1
    endwhile
endfunction

command! -nargs=0 Vcdiff call Vcd_MakeDiff()
command! -nargs=0 Vcshow call Vcd_ShowDiff()
