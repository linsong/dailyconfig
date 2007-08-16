" exo-codereview.vim -- make code reviews easier at Exoweb
" Author: Vincent Wang (linsong dot qizi at gmail dot com)
" Last Change: 
" Created:     
" Requires: 
" Version: 1.0
" Acknowledgements:

":source ~/.vim/plugin/Decho.vim
" per filetype setting
if ! exists("g:exo_codereview")
    let g:exo_codereview = 1

    if !exists('s:buffer_list') " Supports reloading.
      let s:buffer_list = []
    endif

    function! s:GetUserName()
        if exists('g:codereview_username') && !empty(g:codereview_username)
            return g:codereview_username 
        elseif exists('$USERNAME') && &USERNAME != ''
            return $USERNAME
        else
            echo "Please setup your username for svn first. You can do it by: "
            echo "  putting line 'let g:codereview_username=YOURNAME' into your .vimrc "
            return ''
        endif
    endfunction

    function! s:AppendSlashIfNeeded(path_name)
        "remove possible blanks at the end
        let result = substitute(a:path_name, "\\s*$", "", "")
        if result !~ '/$'
            return result . '/'
        else
            return result
        endif
    endfunction

    function! s:GetSvnBaseURL()
        if exists('g:svn_base_url') && !empty(g:svn_base_url)
            return s:AppendSlashIfNeeded(g:svn_base_url)
        else
            echo "Please setup svn code review base URL in your .vimrc. You can do it by: "
            echo "  putting line 'let g:svn_base_url=\"https://nordicbet.dev.exoweb.net/svn/trunk/src\"' into your .vimrc "
            return ''
        endif
    endfunction

    function! s:GenerateCodeReviewComments()
        let username = s:GetUserName()
        if(username=='')
"            :call Decho("user name is empty.")
            return ''
        endif
        let username_line = '== ' . substitute(username, ".*", "\\u\\0", "") . ' =='
        if search('^' . username_line, 'w') > 0
"            :call Decho("You have edited this before")
            return 'Done'
        else
            let svn_base_url = s:GetSvnBaseURL()
            if(svn_base_url=='')
"                :call Decho("SVN base URL is empty")
                return ''
            endif
            let svn_log_cmd = "svn log -vr " . b:svn_version . " " . svn_base_url
            let output_list = []
            :call add(output_list, username_line)
            for line in split(system(svn_log_cmd), '\n')
                let svn_log_line = matchstr(line, '\/trunk\/\S*$')
                if svn_log_line != ""
                    :call add(output_list, "source:" . svn_log_line . "@r" . b:svn_version . ":")
                endif
            endfor
            
            "add a blank line between my comments and old comments 
            if line('$') != 1
                if getline('$') =~ "^\s*$" 
                    if getline(line('$')-1) !~ "^\s*$"
                        :call append(line('$'), '\n')
                    endif
                else
                    :call append(line('$'), '')
                    :call append(line('$'), '')
                endif
            endif

            :call setline(line('$'), output_list)
            unlet svn_log_cmd
            unlet output_list
        endif
"        :call Decho("Code review comments is generated") 
        return 'Done'
    endfunction

    function! s:OpenScratchWindow(fname)
        if exists('+shellslash')
          exec "sview \\\\". a:fname
        else
          exec "sview \\". a:fname
        endif

        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal nobuflisted
        setlocal noswapfile
    endfunction

    function! s:OpenScratchWindowInList(fname, new_window)
        if ! (empty(s:buffer_list) || a:new_window == 1)
            let buffer_win = bufwinnr(s:buffer_list[0])
            if(buffer_win != -1)
              exec buffer_win . 'wincmd w'
              exec 'wincmd c'
            endif
            :call remove(s:buffer_list, 0)
        endif

        :call s:OpenScratchWindow(a:fname)

        :call add(s:buffer_list, bufnr('%'))
    endfunction

    function! s:OpenSVNFileUnderCursor(new_window, svn_version)
        let cur_line = getline('.')
        let svn_file = substitute(cur_line, '^.*\(/trunk/[^@]\+\)@r.*$', '\1', '')
        if strpart(svn_file, 0, 1) != '/'
            echo "You must put your cursor on a source file line to open it"
            return 
        endif
        :call s:OpenScratchWindowInList('[r' . a:svn_version . ']' . svn_file, a:new_window)
        let exo_svn_repo_base_url = s:GetSvnBaseURL()
        if(exo_svn_repo_base_url!="")
            silent exec '0r !svn cat -r ' . a:svn_version . ' ' . exo_svn_repo_base_url . svn_file
        endif
    endfunction

    function! s:OpenSVNDiffFile(latest_version)
        if exists('g:svn_workcopy_path') && !empty(g:svn_workcopy_path)
            exec "lcd " . g:svn_workcopy_path
        endif
"        :call Decho("opensvndifffile")
        let diff_file_name = "[ChangeSet@r" . a:latest_version . "]"
        :call s:OpenScratchWindow(diff_file_name)

        let exo_svn_repo_base_url = s:GetSvnBaseURL()
        if(exo_svn_repo_base_url!="")
            silent exec '0r !svn diff -r ' . (a:latest_version-1) . ':' . a:latest_version . ' ' . exo_svn_repo_base_url
        endif
        :norm gg
    endfunction
endif

" per buffer setting
if ! exists("b:exo_codereview")
    let b:exo_codereview = 1

    setlocal spell 

    map <buffer> <Enter> :call <sid>OpenSVNFileUnderCursor(0, b:svn_version)<CR>
    map <buffer> <C-Enter> :call <sid>OpenSVNFileUnderCursor(1, b:svn_version)<CR>
    
    " init buffer variables
    let b:svn_version = matchstr(expand("%:t:r"), '\d\+')

    let result = s:GenerateCodeReviewComments()
    if(result=='Done')
        :call s:OpenSVNDiffFile(b:svn_version)
    endif
endif
