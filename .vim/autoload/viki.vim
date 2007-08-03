" viki.vim
" @Author:      Thomas Link (mailto:samul AT web de?subject=vim-viki)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-03-25.
" @Last Change: 2007-06-02.
" @Revision:    0.165

if &cp || exists("loaded_viki_auto")
    finish
endif
let loaded_viki_auto = 1

fun! viki#VikiFindNextRegion(name)
    let rx = s:GetRegionStartRx(a:name)
    return search(rx, 'We')
endf

fun! viki#VikiFilesUpdateAll()
    let p = getpos('.')
    try
        norm! gg
        while viki#VikiFindNextRegion('Files')
            call viki#VikiFilesUpdate()
            norm! j
        endwh
    finally
        call setpos('.', p)
    endtry
endf

fun! viki#VikiFilesExec(cmd, bang, ...)
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    if a:0 >= 1 && a:1
        let lb = line('.')
        let le = line('.') + 1
    endif
    let ilen = len(indent)
    let done = []
    for f in s:CollectFileNames(lb, le, a:bang)
        let ff = escape(f, '%#\ ')
        let x = VikiSubstituteArgs(a:cmd, 
                    \ '', ff, 
                    \ 'FILE', f, 
                    \ 'FFILE', ff,
                    \ 'DIR', fnamemodify(f, ':h'))
        if index(done, x) == -1
            exec x
            call add(done, x)
        endif
    endfor
endf

fun! viki#VikiFilesCmd(cmd, bang)
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        exec VikiCmd_{a:cmd} .' '. escape(t, '%#\ ')
    endfor
endf

fun! viki#VikiFilesCall(cmd, bang)
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    let ilen = len(indent)
    for t in s:CollectFileNames(lb, le, a:bang)
        call VikiCmd_{a:cmd}(t)
    endfor
endf

fun! s:CollectFileNames(lb, le, bang)
    let afile = viki#VikiFilesGetFilename(getline('.'))
    let acc   = []
    for l in range(a:lb, a:le - 1)
        let line  = getline(l)
        let bfile = viki#VikiFilesGetFilename(line)
        if s:IsEligibleLine(afile, bfile, a:bang)
            call add(acc, fnamemodify(bfile, ':p'))
        endif
    endfor
    return acc
endf

fun! s:IsEligibleLine(afile, bfile, bang)
    if empty(a:bang)
        return 1
    else
        if isdirectory(a:bfile)
            return 0
        else
            let adir  = isdirectory(a:afile) ? a:afile : fnamemodify(a:afile, ':h')
            let bdir  = isdirectory(a:bfile) ? a:bfile : fnamemodify(a:bfile, ':h')
            let rv = s:IsSubdir(adir, bdir)
            return rv
        endif
    endif
endf

fun! s:IsSubdir(adir, bdir)
    if a:adir == '' || a:bdir == ''
        return 0
    elseif a:adir == a:bdir
        return 1
    else
        return s:IsSubdir(a:adir, fnamemodify(a:bdir, ':h'))
    endif
endf

fun! viki#VikiFilesUpdate()
    let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    " 'vikiFiles', 'vikiFilesRegion'
    call s:DeleteRegionBody(lb, le)
    call viki#VikiDirListing(lh, lb, indent)
endf

fun! viki#VikiDirListing(lhs, lhb, indent)
    let args = s:GetRegionArgs(a:lhs, a:lhb - 1)
    let patt = get(args, 'glob', '')
    " TLogVAR patt
    if empty(patt)
        echoerr 'Viki: No glob pattern defnied: '. string(args)
    else
        let p = getpos('.')
        let t = @t
        try
            " let style = get(args, 'style', 'ls')
            " let ls = VikiGetDirListing_{style}(split(glob(patt), '\n'))
            let ls = split(glob(patt), '\n')
            " TLogVAR ls
            let types = get(args, 'types', '')
            " TLogVAR ls
            if !empty(types)
                let show_files = stridx(types, 'f') != -1
                let show_dirs  = stridx(types, 'd') != -1
                call filter(ls, '(show_files && !isdirectory(v:val)) || (show_dirs && isdirectory(v:val))')
            endif
            let filter = get(args, 'filter', '')
            if !empty(filter)
                call filter(ls, 'v:val =~ filter')
            endif
            let exclude = get(args, 'exclude', '')
            if !empty(exclude)
                call filter(ls, 'v:val !~ exclude')
            endif
            let order = get(args, 'order', '')
            " if !empty(order)
            "     if order == 'd'
            "         call sort(ls, 's:SortDirsFirst')
            "     endif
            " endif
            let list = split(get(args, 'list', ''), ',\s*')
            call map(ls, 'a:indent.s:GetFileEntry(v:val, list)')
            let @t = join(ls, "\<c-j>") ."\<c-j>"
            exec 'norm! '. a:lhb .'G"tP'
        finally
            let @t = t
            call setpos('.', p)
        endtry
    endif
endf

" fun! VikiGetDirListing_ls(files)
"     return a:files
" endf

fun! s:GetFileEntry(file, list)
    " let prefix = substitute(a:file, '[^/]', '', 'g')
    " let prefix = substitute(prefix, '/', repeat(' ', &shiftwidth), 'g')
    let attr = []
    if index(a:list, 'detail') != -1
        let type = getftype(a:file)
        if type != 'file'
            if type == 'dir'
                call add(attr, 'D')
            else
                call add(attr, type)
            endif
        endif
        call add(attr, strftime('%c', getftime(a:file)))
        call add(attr, getfperm(a:file))
    else
        if isdirectory(a:file)
            call add(attr, 'D')
        endif
    endif
    let f = []
    let d = s:GetDepth(a:file)
    " if index(a:list, 'tree') == -1
    "     call add(f, '[[')
    "     call add(f, repeat('|-', d))
    "     if index(attr, 'D') == -1
    "         call add(f, ' ')
    "     else
    "         call add(f, '-+ ')
    "     endif
    "     call add(f, fnamemodify(a:file, ':t') .'].]')
    " else
        if index(a:list, 'flat') == -1
            call add(f, repeat(' ', d * &shiftwidth))
        endif
        call add(f, '[['. a:file .']!]')
    " endif
    if !empty(attr)
        call add(f, ' {'. join(attr, '|') .'}')
    endif
    let c = get(s:savedComments, a:file, '')
    if !empty(c)
        call add(f, c)
    endif
    return join(f, '')
endf

fun! s:GetDepth(file)
    return len(substitute(a:file, '[^/]', '', 'g'))
endf

fun! s:GetRegionArgs(ls, le)
    let t = @t
    " let p = getpos('.')
    try
        let t = s:GetBrokenLine(a:ls, a:le)
        let t = matchstr(t, '^\s*#\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)\zs.\{-}\ze<<$')
        let args = {}
        let rx = '^\s*\(\(\S\{-}\)=\("\(\(\"\|.\{-}\)\{-}\)"\|\(\(\S\+\|\\ \)\+\)\)\|\(\w\)\+!\)\s*'
        let s  = 0
        let sm = len(t)
        while s < sm
            let m = matchlist(t, rx, s)
            if empty(m)
                echoerr "Viki: Can't parse argument list: ". t
            else
                let key = m[2]
                if !empty(key)
                    let val = empty(m[4]) ? m[6] : m[4]
                    if val =~ '^".\{-}"'
                        let val = val[1:-2]
                    endif
                    let args[key] = substitute(val, '\\\(.\)', '\1', 'g')
                else
                    let key = m[8]
                    if key == '^no\u'
                        let antikey = substitute(key, '^no\zs.', '\l&', '')
                    else
                        let antikey = 'no'. substitute(key, '^.', '\u&', '')
                    endif
                    let args[key] = 1
                    let args[antikey] = 0
                endif
                let s += len(m[0])
            endif
        endwh
        return args
    finally
        let @t = t
        " call setpos('.', p)
    endtry
endf

fun! s:GetBrokenLine(ls, le)
    let t = @t
    try
        exec 'norm! '. a:ls .'G"ty'. a:le .'G'
        let @t = substitute(@t, '[^\\]\zs\\\n\s*', '', 'g')
        let @t = substitute(@t, '\n*$', '', 'g')
        return @t
    finally
        let @t = t
    endtry
endf

fun! s:GetRegionStartRx(...)
    let name = a:0 >= 1 && !empty(a:1) ? '\(\('. a:1 .'\>\)\)' : '\([A-Z]\([a-z][A-Za-z]*\)\?\>\|!!!\)'
    let rx_start = '^\([[:blank:]]*\)#'. name .'\(\\\n\|.\)\{-}<<\(.*\)$'
    return rx_start
endf

fun! s:GetRegionGeometry(...)
    let p = getpos('.')
    try
        norm! $
        let rx_start = s:GetRegionStartRx(a:0 >= 1 ? a:1 : '')
        let hds = search(rx_start, 'cbWe')
        if hds > 0
            let hde = search(rx_start, 'ce')
            let hdt = s:GetBrokenLine(hds, hde)
            let hdm = matchlist(hdt, rx_start)
            let hdi = hdm[1]
            let rx_end = '\V\^\[[:blank:]]\*'. escape(hdm[5], '\') .'\[[:blank:]]\*\$'
            let hbe = search(rx_end)
            if hds > 0 && hde > 0 && hbe > 0
                return [hds, hde + 1, hbe, hdi]
            else
                echoerr "Viki: Can't determine region geometry: ". string([hds, hde, hbe, hdi, hdm, rx_start, rx_end])
            endif
        else
            echoerr "Viki: Can't determine region geometry: ". join([rx_start], ', ')
        endif
        return [0, 0, 0, '']
    finally
        call setpos('.', p)
    endtry
endf

fun! s:DeleteRegionBody(...)
    if a:0 >= 2
        let lb = a:1
        let le = a:2
    else
        let [lh, lb, le, indent] = s:GetRegionGeometry('Files')
    endif
    call s:SaveComments(lb, le - 1)
    if le > lb
        exec 'norm! '. lb .'Gd'. (le - 1) .'G'
    endif
endf

fun! s:SaveComments(lb, le)
    let s:savedComments = {}
    for l in range(a:lb, a:le)
        let t = getline(l)
        let k = viki#VikiFilesGetFilename(t)
        if !empty(k)
            let s:savedComments[k] = viki#VikiFilesGetComment(t)
        endif
    endfor
endf

fun! viki#VikiFilesGetFilename(t)
    return matchstr(a:t, '^\s*\[\[\zs.\{-}\ze\]!\]')
endf

fun! viki#VikiFilesGetComment(t)
    return matchstr(a:t, '^\s*\[\[.\{-}\]!\]\( {.\{-}}\)\?\zs.*')
endf

