if ! exists("g:sco_include_key_mappings")
    finish
endif

vnoremap <buffer> w :Wrap<CR>
vnoremap <buffer> a :AllignRange<CR>
vnoremap <buffer> o :MultiOpen<CR>

nnoremap <buffer> <CR> :Enter<CR>
nnoremap <buffer> <C-CR> :ForceEnter<CR>
nnoremap <buffer> c<Space>p :Preview<CR>
nnoremap <buffer> c<Space>a :Allign<CR>

nnoremap c<Space>g :SCOGlobal expand('<cword>')<CR>
nnoremap c<Space>c :SCOSymbol expand('<cword>')<CR>
nnoremap c<Space>s :SCOSaveSearch<CR>
nnoremap c<Space>t :SCOTag ''<CR>
nnoremap c<Space>w :SCOWhoCall expand('<cword>')<CR>
nnoremap c<Space>i :SCOInclude expand('<cfile>')<CR>
nnoremap c<Space>f :SCOFile expand('<cfile>')<CR>
nnoremap c<Space>b :SCOBuffer<CR>
nnoremap c<Space>m :SCOMark<CR>
nnoremap c<Space>n :SCOMarkSmart<CR>
nnoremap c<Space>r :SCOReMark<CR>

nnoremap <C-Left> :SCOPrevious<CR>
nnoremap <C-Right> :SCONext<CR>
nnoremap <C-Up> :SCOUp<CR>
nnoremap <C-Down> :SCODown<CR>

