" Author: Shlomi Fish
" Homepage: http://www.shlomifish.org/
" Email: shlomif@cpan.org
" Date: 10 February 2005
" License: MIT X11 ( http://www.opensource.org/licenses/mit-license.php )
" Version: 0.4.0
"
"
" To use: put this in ~/.vim/plugin/ and then type something like:
"
" <<<
"   :'a,'eRs mypat
" >>>
" to search using the pattern mypat.

function! Range_Search(mypat, start_line, end_line)
    let full_pat = '\%>' . a:start_line . "l" . '\%<' . a:end_line . "l" . a:mypat
    exe '/' . full_pat
    let @/ = full_pat
    norm n
endfunction

command -range -nargs=1 Rs call Range_Search(<f-args>,<line1>,<line2>)
command -range -nargs=1 RS call Range_Search(<f-args>,<line1>,<line2>)

" Changelog:
" 0.4.0:
"   - Added a more meaningful comment at the top.
"   - Added the range-search.txt file.
"   - Converted into a .zip file. 
"
" 0.2.0:
"   first release.
