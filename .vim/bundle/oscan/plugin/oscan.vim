command! -nargs=* -complete=custom,railmoon#oscan#complete OScan :call railmoon#oscan#open(<f-args>)

nnoremap <silent> 0t :OScan file<CR>
nnoremap <silent> 0c :OScan file constructor<CR>
nnoremap <silent> 0d :OScan file destructor<CR>
nnoremap <silent> 0o :OScan file object<CR>
nnoremap <silent> 0g :OScan file <C-R><C-W><CR>
nnoremap <silent> 0s :OScan search<CR>
nnoremap <silent> 0S :OScan multiline_search<CR>
nnoremap <silent> 0as :OScan search_in_scope<CR>
nnoremap <silent> 0b :OScan buffers<CR>
nnoremap <silent> 0f :OScan files<CR>
nnoremap <silent> 0F :OScan files <C-R>=fnamemodify(@%, ":t:r")<CR><CR><BS>
nnoremap <silent> 0w :OScan windows<CR>
nnoremap <silent> 0v :OScan vims<CR>
nnoremap <silent> 0p :OScan paste<CR>
nnoremap <silent> 0h :OScan changes<CR>
nnoremap <silent> 0m :OScan marks<CR>
nnoremap <silent> 0M :OScan marks global user<CR>
nnoremap <silent> 0u :OScan taglist_under_cursor<CR>
nnoremap <silent> 0n :OScan definition_declaration<CR>

function! s:FindPatternInFile(pattern)
    let search_pattern = @/
    let @/ = a:pattern
    OScan search
    let @/ = search_pattern
endfunction

nnoremap <silent> 0i :call <SID>FindPatternInFile('^\s*#include')<CR>

" repeat last Oscan session
nnoremap <silent> 0l :OScan last<CR>
nnoremap <silent> 0k :OScan lastup<CR>
nnoremap <silent> 0j :OScan lastdown<CR>

