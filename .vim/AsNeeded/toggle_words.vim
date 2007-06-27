" toggle_words.vim
" Author: Vincent Wang (linsong dot qizi at gmail dot com)
" Created:  Fri Oct 13 07:51:16 CST 2006
" Requires: Vim Ver7.0+ 
" Version:  1.0
" TODO: 
"
" Documentation: 
"   The purpose of this plugin is very simple, it can toggle words among
"   ['true', 'false'], ['on', 'off'], ['yes', 'no'], ['if', 'elseif', 'else',
"   'endif'] etc . 
"   To use it, move the cursor on some words like "true", "false", "yes", etc, 
"   call command :ToggleWord<CR>(or just press ,t).
"   It will search the candicates words to toggle based on
"   current filetype, for example, you can put the following configuration
"   into your .vimrc to define some words for python:
"      let g:toggle_words_dict = {'python': [['if', 'elif', 'else'], ['True',
"      'False']]}
"   
"   There are some default words for toggling predefined in the
"   script(g:_toogle_words_dict) that will work for all filetypes.
"   Any comment, suggestion, bug report are welcomed. 

if v:version < 700
    "TODO: maybe I should make this script works under vim7.0
    echo "This script required vim7.0 or above version." 
    finish 
endif

if exists("g:load_toggle_words")
   finish
endif

let s:keepcpo= &cpo
set cpo&vim

let g:load_toggle_words = "1.0"

let g:_toggle_words_dict = {'*': [['true', 'false'], ['on', 'off'], ['yes', 'no'], ['+', '-'], ['define', 'undef'], ['if', 'elseif', 'else', 'endif'], ['>', '<'], ['{', '}'], ['(', ')'], ['[', ']'], ['success', 'failure'], ['True', 'False'],  ],  }

if exists('g:toggle_words_dict')
    :call extend(g:_toggle_words_dict, g:toggle_words_dict)
endif

function! s:ToggleWord()
    let cur_filetype = &filetype
    if ! has_key(g:_toggle_words_dict, cur_filetype)
        let words_candicates_array = g:_toggle_words_dict['*']
    else
        let words_candicates_array = g:_toggle_words_dict[cur_filetype] + g:_toggle_words_dict['*']
    endif
    let cur_word = expand("<cword>")
    for words_candicates in words_candicates_array
        let index = index(words_candicates, cur_word)
        if index != -1
            let new_word_index = (index+1)%len(words_candicates)
            let new_word = words_candicates[new_word_index]
            " use the new word to replace the old word
            exec "norm ciw" . new_word . ""
            break
        endif
    endfor
endfunction

command! ToggleWord :call <SID>ToggleWord() <CR>

let &cpo= s:keepcpo
unlet s:keepcpo
