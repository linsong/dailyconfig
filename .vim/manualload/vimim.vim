" ===============================================================
"        vimim -- input method by vim, of vim, for vimmers
" ===============================================================
"         File:  vimim.vim
"       Author:  Sean Ma <maxiangjiang_at_cornell_dot_edu>
"  Last Change:  January 11, 2009
"          URL:  http://vim.sourceforge.net/scripts/script.php?script_id=2506
"  Description:  This is a vim plugin designed as an independent
"                IM (Input Method) using vim omni completion feature.
"                Chinese language is picked to demo its power.
"                The input method can be defined as anything.
"     Features:  - Chinese can be input if it can be read within vim
"                - It is independent of the Operating System
"                - It is independent of vim "mbyte-XIM/mbyte-IME" API
"                - No limitation on input methods, which can be combined
"                - Flexible data file format
"   Quick Demo:  (1) source this script file by :source %
"                (2) when in Insert mode, type: chin<C-X><C-U>
" Installation:  (1) download any data file from the link below
"                (2) save this file and data file in the plugin directory
"    Data File:  http://maxiangjiang.googlepages.com/vimim.py
"                http://maxiangjiang.googlepages.com/vimim.wb
"                http://maxiangjiang.googlepages.com/vimim.cj
"                http://maxiangjiang.googlepages.com/vimim.en
"                http://maxiangjiang.googlepages.com/vimim.qk
"                http://maxiangjiang.googlepages.com/vimim.4j
" Latest Script: http://maxiangjiang.googlepages.com/vimim.vim
"  Screen Shot:  http://maxiangjiang.googlepages.com/vimim.gif
"  Chinese URL:  http://maxiangjiang.googlepages.com/vimim.html
" ===============================================================


" ===============================================================
"                       The vimim Backgrounds
" ===============================================================

" Design Goals:
" -------------
"   (1) without any negative impact to vim if vimim is not used
"   (2) with decent performance once vimim is triggered

" Assumptions:
" ------------
"   (1) Chinese can be read from within vim
"   (2) The utf-8 format is used both in memory and on disk
"   (3) The .vimrc is correctly set, for example, on my XP box:
"       :set enc = utf8
"       :set gfn = Courier_New:h12:w7
"       :set gfw = SimSun-18030,Arial_Unicode_MS

" About the data file:
" --------------------
" The data file has to be sorted (:sort) before it can be used.
" The basic format of the data file looks like:
"
" +-------+---------+---------+
" |   A   |    B    |   C     |
" +-------+---------+---------+
" | <key> | <space> | <value> |
" +=======+=========+=========+
" |  ma   |         |    马   |
" +-------+---------+---------+
"
" The <key> is what is typed in alphabet, ready to be replaced.
" The <value>, separated by spaces, is what will be input.
" Column B and C can be repeated without limitation.
"
" In principle, any input method (Wubi, Pinyin, English, etc)
" can be used as long as a valid data file is made available.
" The advanced vimim users can create their own input method by
" using their own data file.
"
" Several sample data files are provided, ready to be played.
" --------------  ---------------------------
"   vimim.vim           vimim data file
" --------------  ---------------------------
"    vimim.py       input method for PinYin
"    vimim.wb       input method for WuBi
"    vimim.cj       input method for CangJie
"    vimim.en       input method for English
"    vimim.qk       input method for Quick
"    vimim.4j       input method for 4 Corner
" --------------  ---------------------------

" About vimim Options:
" --------------------
"  (1) i_<C-^> => to pick up the default right away
"      let g:vimim_i_ctrl6=1
"      ---------------------
"      g:vimim_i_ctrl6
"      Note: purpose: define i_<C-^> as <C-X><C-U><C-U><C-P><C-N>
"            pro: input the default right away
"            default: 0
"
"  (2) To make vimim Insert Mode more "intelligent"
"      => toggle the use of <Space> to trigger the popup menu
"      => toggle punctuation: , .  : ; ? \ () <> []
"      => toggle options 'pumheight', 'completeopt', 'lazyredraw'
"      => toggle cursor color to identify the 'IM mode'
"      => toggle status line  to identify the 'IM mode'
"      Note: convenient and consistent to other IM
"      (2.1) To do it manually by using i_<C-\>
"            let g:vimim_insertmode_toggle=1
"      (2.2) To do it automatically
"            let g:vimim_insertmode_auto_toggle=1
"
"  (3) To control your data files
"      (3.1) set a default data file of your choice
"            let g:vimim_datafile="your_default_data_file"
"      (3.2) set a 2nd data file if you want
"            let g:vimim_datafile2="your_second_data_file"
"      (3.3) switch those two data file on the fly

" References:
" -----------
" (1) http://en.wikipedia.org/wiki/Input_method_editor
" (2) http://en.wikipedia.org/wiki/Chinese_input_methods_for_computers
" (3) http://blah.blogsome.com/2006/06/27/vim7_tut_oc/
" (4) http://blah.blogsome.com/2007/08/23/vim_cn_faq/
" (5) http://www.vim.org/scripts/script.php?script_id=1879
" (6) http://vim.sourceforge.net/scripts/script.php?script_id=999
" (7) http://maxiangjiang.googlepages.com/chinese.html
" (8) http://groups.google.com/group/vim_use/topics


" ===============================================================
"                           The vimim Core
" ===============================================================
if exists("loaded_vimim_VIM")
  finish
endif
let loaded_vimim_VIM=1

if !exists("g:vimim_datafile")
    let g:vimim_datafile=0
endif

let path = expand("<sfile>:p:h")."/"
let datafile  =        g:vimim_datafile
let datafileA = path . g:vimim_datafile
let datafileB = path . "vimim.py"
let datafileC = path . "vimim.wb"
let datafileD = path . "vimim.cj"
let datafileE = path . "vimim.en"
let datafileF = path . "vimim.qk"
let datafileG = path . "vimim.4j"

if filereadable(datafile)
    let s:lines1 = readfile(datafile)
elseif filereadable(datafileA)
    let s:lines1 = readfile(datafileA)
elseif filereadable(datafileB)
    let s:lines1 = readfile(datafileB)
elseif filereadable(datafileC)
    let s:lines1 = readfile(datafileC)
elseif filereadable(datafileD)
    let s:lines1 = readfile(datafileD)
elseif filereadable(datafileE)
    let s:lines1 = readfile(datafileE)
elseif filereadable(datafileF)
    let s:lines1 = readfile(datafileF)
elseif filereadable(datafileG)
    let s:lines1 = readfile(datafileG)
else
    let line1 = "ma 马 吗 碼 码"
    let line2 = "ma 馬"
    let line3 = "ma 妈"
    let line4 = "china   中国"
    let line5 = "chinese 中国人"
    let line6 = "chinese 中文 汉字"
    let s:lines1 = [line1,line2,line3,line4,line5,line6]
endif

let s:lines = s:lines1
let s:DataFileToggle=0
" supporting switch datafile on the fly
" -------------------------------------
if !exists("g:vimim_datafile2")
    let g:vimim_datafile2=0
else
   imap <F11> <C-O>:call VimIM_Datafile_Toggle()<CR>
   let datafile2  = g:vimim_datafile2
   let datafile2A = path . datafile2
   if filereadable(datafile2)
      let s:lines2 = readfile(datafile2)
   elseif filereadable(datafile2A)
      let s:lines2 = readfile(datafile2A)
   endif
endif
" -------------------------------
function! VimIM_Datafile_Toggle()
" -------------------------------
    if s:DataFileToggle==0
      let s:DataFileToggle=1
      let s:lines = s:lines2
    else
      let s:DataFileToggle=0
      let s:lines = s:lines1
    endif
endfunction


set completefunc=VimIM
" --------------------------
function! VimIM(start, base)
" --------------------------
  if a:start

    let current_line = getline('.')
    let start_col = col('.')-1

    " to avoid hanging on triggering non-word char
    " --------------------------------------------
    if start_col == 0 || current_line[start_col-1] !~ '\w'
       return
    endif

    " if do case sensitive search, use =~#
    " --------------------------------------------
    while start_col > 0 && current_line[start_col-1] =~ '\w'
      let start_col -= 1
    endwhile
    return start_col

  else

    let errmsg = '-- User defined completion (^U^N^P) Pattern not found'

    let abase = a:base

    " to avoid hanging on empty or non-word
    " -------------------------------------
    if strlen(abase) < 1
       return
    endif

    " to avoid hanging on pattern with all zeroes
    " -------------------------------------------
    if abase =~ '^0\+'
       return [nr2char(9675)]
    endif

    " to avoid hanging on pattern with leading zero
    " assuming only 4 digits for 4 corner data file
    " ---------------------------------------------
    if abase >0 && abase < 1000
       let abase = printf('%04o',abase)
    else
       let abase = printf('%s',abase)
    endif

    " no more cache, no more full range scan
    " find out the exact range on the sorted data file
    " ------------------------------------------------
    let pat = '^' . abase

    let start_match = 0
    let next_match = 1
    let start_match = match(s:lines, pat, start_match)

    " to limit search where short characters are typed
    " the default setting is hard-coded to be 2
    " for example, a<C-^> only shows maps for a only, not 'aiqing'
    " ------------------------------------------------
    if strlen(a:base) <= 2
      " ------------------------------------------------
        let pat_one = pat . '\> '
      " only works when the datafile is sorted by len(word)
      " let pat_one_more = pat . '\w\> '
      " let pat = pat_one . '\|' .  pat_one_more
      " ------------------------------------------------
      let pat = pat_one
    endif

    let counts = 0
    while next_match >= 0
      let counts += 1
      let next_match = match(s:lines, pat, start_match, counts)
    endwhile

    " now simply store the list from start index to end index
    " -------------------------------------------------------
    let end_match = start_match + counts - 2
    let matched_range_list = s:lines[start_match : end_match]

    let popupmenu_list = []
    for line in matched_range_list
      let one_line_list = split(line,'\s\+')
      let key = remove(one_line_list,0)

      for value in one_line_list
         let menu_dict = {}
         let menu_dict["menu"] = key
         let menu_dict["word"] = value
         call add(popupmenu_list, menu_dict)
      endfor

    endfor
    return popupmenu_list
  endif
endfunction

" ===============================================================
"                          The vimim Helper
" ===============================================================
" ------------------------------------
if !exists("g:vimim_i_ctrl6")
    let g:vimim_i_ctrl6=0
endif
" ------------------------------------
if g:vimim_i_ctrl6
    imap <C-^> <C-X><C-U><C-U><C-P><C-N>
endif
" ------------------------------------

" ------------------------------------
if !exists("g:vimim_insertmode_toggle")
    let g:vimim_insertmode_toggle=0
endif
" ------------------------------------
if !exists("g:vimim_insertmode_auto_toggle")
    let g:vimim_insertmode_auto_toggle=0
endif
" ------------------------------------
if !exists("g:vimim_punctation_english")
    let g:vimim_punctation_english=0
endif
" ------------------------------------
if !exists("g:vimim_punctuation_toggle")
    let g:vimim_punctuation_toggle=0
endif
" ------------------------------------

" ------------------------------
function! VimIM_Punctuation_On()
" ------------------------------
    let s:vimim_Punctuation=1
    inoremap  (  <C-V>uff08
    inoremap  )  <C-V>uff09
    inoremap  {  <C-V>u300e
    inoremap  }  <C-V>u300f
    inoremap  [  <C-V>u3010
    inoremap  ]  <C-V>u3011
    inoremap  <  <C-V>u300a
    inoremap  >  <C-V>u300b
    inoremap  +  <C-V>uff0b
    inoremap  -  <C-V>uff0d
    inoremap  *  <C-V>u00d7
    inoremap  =  <C-V>uff1d
    inoremap  /  <C-V>u00f7
    inoremap  ,  <C-V>uff0c
    inoremap  .  <C-V>u3002
    inoremap  :  <C-V>uff1a
    inoremap  ;  <C-V>uff1b
    inoremap  ?  <C-V>uff1f
    inoremap  !  <C-V>uff01
    inoremap  ~  <C-V>uff5e
    inoremap  #  <C-V>uff03
    inoremap  %  <C-V>uff05
    inoremap  $  <C-V>uffe5
    inoremap  &  <C-V>u203b
    inoremap  @  <C-V>u25ce
    inoremap  ^  <C-V>u2026<C-V>u2026
    inoremap  _  <C-V>u2014<C-V>u2014
    inoremap  "  <C-V>u201c<C-V>u201D
    inoremap  '  <C-V>u2018<C-V>u2019
endfunction
" -------------------------------
function! VimIM_Punctuation_Off()
" -------------------------------
    let s:vimim_Punctuation=0
    imap  (  (
    imap  )  )
    imap  {  {
    imap  }  }
    imap  [  [
    imap  ]  ]
    imap  <  <
    imap  >  >
    imap  +  +
    imap  -  -
    imap  *  *
    imap  /  /
    imap  =  =
    imap  ,  ,
    imap  .  .
    imap  :  :
    imap  ;  ;
    imap  ?  ?
    imap  !  !
    imap  ~  ~
    imap  #  #
    imap  %  %
    imap  $  $
    imap  &  &
    imap  @  @
    imap  ^  ^
    imap  _  _
    imap  "  "
    imap  '  '
endfunction


let s:saved_pumheight=&pumheight
let s:saved_completeopt=&completeopt
let s:saved_lazyredraw=&lazyredraw
let s:saved_iminsert=&iminsert
" -----------------------------
function! VimIM_InsertMode_On()
" -----------------------------
    if g:vimim_punctation_english == 0
      call VimIM_Punctuation_On()
    endif
    let s:iToggle=1
    let s:saved_pumheight=&pumheight
    let s:saved_completeopt=&completeopt
    let s:saved_lazyredraw=&lazyredraw
    let s:saved_iminsert=&iminsert
    set pumheight=10
    set completeopt=menu,longest
    set nolazyredraw
    set iminsert=1
    highlight Cursor   guifg=bg guibg=Green
    highlight CursorIM guifg=bg guibg=Green
    imap <Space> <C-R>=VimIMSpace1()<CR><C-R>=VimIMSpace2()<CR>
endfunction
" ------------------------------
function! VimIM_InsertMode_Off()
" ------------------------------
    if g:vimim_punctation_english == 0
      call VimIM_Punctuation_Off()
    endif
    let s:iToggle=0
    let &pumheight=s:saved_pumheight
    let &completeopt=s:saved_completeopt
    let &lazyredraw=s:saved_lazyredraw
    let &iminsert=s:saved_iminsert
    highlight Cursor   guifg=bg guibg=fg
    highlight CursorIM guifg=bg guibg=fg
    imap <Space> <Space>
endfunction


let s:vimim_Punctuation=0
" ----------------------------------
function! VimIM_Punctuation_Toggle()
" ----------------------------------
    if s:vimim_Punctuation == 0
       call VimIM_Punctuation_On()
    else
       call VimIM_Punctuation_Off()
    endif
endfunction
" ------------------------------------
if g:vimim_punctuation_toggle
    imap <S-F11> <C-O>:call VimIM_Punctuation_Toggle()<CR>
endif

" ---------------------
function! VimIMSpace1()
" ---------------------
    if getline('.')[col('.')-2] !~ '\w' || pumvisible()
        return ' '
    else
        return "\<C-X>\<C-U>"
    endif
endfunction

" ---------------------
function! VimIMSpace2()
" ---------------------
    if pumvisible()
        return "\<C-N>\<C-P>\<C-N>"
    else
        return ""
    endif
endfunction


let s:iToggle=0
let s:iState=0
" ---------------------------------
function! VimIM_InsertMode_Toggle()
" ---------------------------------
    if s:iToggle==0
      call VimIM_InsertMode_On()
    else
      call VimIM_InsertMode_Off()
    endif
endfunction

" -----------------------
function! VimIM_iToggle()
" -----------------------
    if s:iToggle==1
        call VimIM_InsertMode_On()
    else
        call VimIM_InsertMode_Off()
    endif
endfunction


if g:vimim_insertmode_toggle
    imap <C-\> <C-R>=FuncExec("VimIM_InsertMode_Toggle()")<CR>
endif
" ---------------------
function! FuncExec(fun)
" ---------------------
    execute 'call ' a:fun
    return " "
endfunction


if g:vimim_insertmode_auto_toggle
    autocmd InsertEnter * let s:iToggle=s:iState|call VimIM_iToggle()
    autocmd InsertLeave * let s:iState=s:iToggle|call VimIM_InsertMode_Off()
endif


