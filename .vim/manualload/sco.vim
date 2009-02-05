" File: sco.vim
" Author: Nickolay Golubev
" Email: golubev.nikolay@gmail.com
"
" This script allow to work with cscope programm inside vim
" You can easily store cscope results and filter them
" Mark system allow to store interesting places of code for future analyse
"
" Create new yourname.sco file and read help
" Please email me problems

if exists('g:sco_plugin_loaded')
   finish
endif

let g:sco_plugin_loaded = 1

if ! exists('g:sco_default_db')
	let g:sco_default_db = "cscope.out"
endif

if ! exists('g:sco_default_tags')
	let g:sco_default_tags = "tags"
endif

if ! exists('g:sco_default_exe')
	let g:sco_default_exe = "cscope"
endif

let s:smart_mark_pattern_comment = '\s\+```\(.*[^>]\)>>.*$'
let s:smart_mark_pattern_without_comment = '@\s\+\(\S\+\)\s\+\(\d*\)\s\(.*\)'
let s:smart_mark_pattern = s:smart_mark_pattern_without_comment.s:smart_mark_pattern_comment

let s:line_to_append = -1

let s:sco_settings = {}
let s:sco_requests = {0:'symbol', 1:'global',4:'calling',5:'text',6:'grep',7:'file', 8:'include'}
let s:last_sco_buffer = -1
let s:buffer_to_append = -1
let s:preview = 0
let s:kind_dictionary = {'_c':'class', '_g':'enum','e':'enum', '_s':'struct','f':'method', 'm':'member', 't':'typedef'}

let s:ResultLineNumber = 0

" compare tag elements for sort
function! s:SortElementsByNamespaceFunction(tag1, tag2)
    let ns1 = a:tag1['namespace']
    let ns2 = a:tag2['namespace']
    let kind1 = a:tag1['kind']
    let kind2 = a:tag2['kind']

    if ns1 < ns2
        return -1
    endif
    if ns1 > ns2
        return 1
    endif

    if ns1 == ns2
        if kind1 < kind2
            return -1
        endif
        if kind1 > kind2
            return 1
        endif

        if kind1 == kind2
            return 0
        endif
    endif
endfunction!

function! s:SortNamesInOrderFunction(tag1, tag2)
    let name1 = a:tag1['name']
    let name2 = a:tag2['name']

    if name1 == name2 
        return 0
    endif

    if name1 > name2
        return 1
    endif

    if name1 < name2
        return -1
    endif
endfunction
function! s:ListCompare(list1, list2)
    let len1 = len(a:list1)
    let len2 = len(a:list2)

    let minlen = len1 > len2 ? len2 : len1

    for i in range(minlen)
        if a:list1[i] == a:list2[i]
            continue
        endif

        if a:list1[i] > a:list2[i]
            return 1
        else
            return -1
        endif
    endfor
        
    return len1 > len2 ? 1 : -1
endfunction

function! s:InNamespace(parent, child)
    let list1 = split(a:parent, '::')
    let list2 = split(a:child, '::')

    let len1 = len(list1)
    let len2 = len(list2)

    let minlen = len1 > len2 ? len2 : len1
    for i in range(minlen)
        if list1[i] != list2[i]
            return 0
        endif
    endfor
    return 1
endfunction

function! s:SortElementsByNamespaceFunction2(tag1, tag2)
    let ns1 = a:tag1['namespace']
    let ns2 = a:tag2['namespace']
    let kind1 = a:tag1['kind']
    let kind2 = a:tag2['kind']

    let ns_l1 = split(ns1, '::')
    let ns_l2 = split(ns2, '::')

    if ns_l1 == ns_l2
        if kind1 < kind2
            return -1
        endif
        if kind1 > kind2
            return 1
        endif

        if kind1 == kind2
            return 0
        endif
    endif

    return s:ListCompare(ns_l1, ns_l2)
endfunction!

" function add field to dictionary 'namespace' to use instead of 'class', 'enum', etc.
" set newnamespace equal 1 if it is 'class', 'enum', etc.
function! s:ExpandTagElement(tag_element)
    let result = a:tag_element

    let kind = result['kind']
    let result['namespace'] = ''
    let result['newnamespace'] = 0

    if has_key(result, 'class')
        let result['namespace'] = result['class']
    elseif has_key(result, 'struct')
        let result['namespace'] = result['struct']
    elseif has_key(result, 'enum')
        let result['namespace'] = result['enum']
    endif

    if kind == 'c' || kind == 'g' || kind == 's'
        let result['newnamespace'] = 1
        let result['kind'] = '_'.kind
        if result['namespace'] != '' 
            let result['namespace'] .= '::'.result['name']
        else
            let result['namespace'] .= result['name']
        endif
    endif

    return result
endfunction

function! s:GatherClassInfo(class_name)
    let result = []
    let tag_list = taglist('.*')


    let reg_class_name = '^'.a:class_name.'[:!]'

    " move through all tags in tag file
    for tag_element in tag_list
        let ex_tag_element = s:ExpandTagElement(tag_element)
        let name = ex_tag_element['name']
        let kind = ex_tag_element['kind']

        if (kind == '_c' || kind == '_s') && name == a:class_name
            call add(result, ex_tag_element)
            continue
        endif

        let parent_name = ex_tag_element['namespace'].'!'
        if parent_name =~ reg_class_name
            call add(result, ex_tag_element)
        endif
    endfor

    return result
endfunction

function! s:GatherAllClasseInfo()
    let result = []
    let tag_list = taglist('.*')

    " move through all tags in tag file
    for tag_element in tag_list
        let ex_tag_element = s:ExpandTagElement(tag_element)

        if ex_tag_element['namespace'] != ''
            call add(result, ex_tag_element)
        endif
    endfor

    return result
endfunction

function! s:GetPrototype(element)
    let kind = a:element['kind']

    if kind == '_c'
        return a:element['name']
    endif

    if kind == '_s'
        return a:element['name']
    endif

    if kind == '_g'
        return a:element['name']
    endif
    
    return a:element['name']
endfunction

function! s:AddResultLine(line)
    call append( s:ResultLineNumber, a:line )
    let s:ResultLineNumber += 1
endfunction

function! s:PromptByKind(kind)
    if a:kind == 'm'
        return 'Members'
    endif

    if a:kind == 'f'
        return 'Methods'
    endif

    if a:kind == 't'
        return 'Typedefs'
    endif

    if a:kind == '_c'
        return 'class'
    endif

    if a:kind == '_s'
        return 'struct'
    endif

    if a:kind == '_g'
        return 'enum'
    endif
endfunction

function! s:ShowTagElement(element)
    let namespace = a:element['namespace']
    let kind = a:element['kind']
    let name = a:element['name']

    let kind_prompt = ''
    if has_key(s:kind_dictionary, kind)
        let kind_prompt = s:kind_dictionary[kind]
    endif

    if kind == 'f' && namespace == ''
        let kind_prompt = 'function'
    endif

    if a:element['newnamespace'] == 1
        let name = ''
    endif

    if namespace != '' && name != ''
        let namespace .= '::'
    endif

    let caption = kind_prompt.' '.namespace.name
    " suppose we have cmd as search pattern
    let cmd = a:element['cmd']
    let reg_pattern = '\/\^\(.*\)\$\/'
    let search_line = substitute(cmd, reg_pattern, '\1', '')

    let line = s:CreateSmartMarkLine(a:element['filename'], search_line, 1, caption)
    call s:AddResultLine(line)
endfunction

function! s:ShowElement(element)
    let name = a:element['name']
    let namespace = a:element['namespace']
    let kind = a:element['kind']

    " suppose we have cmd as search pattern
    let cmd = a:element['cmd']
    let reg_pattern = '\/\^\(.*\)\$\/'
    let search_line = substitute(cmd, reg_pattern, '\1', '')

    let prompt = s:GetPrototype(a:element)

    if kind == '_c'
        let prompt = 'definition'
    elseif kind == '_s'
        let prompt = 'definition'
    elseif kind == '_g'
        let prompt = 'defintion'
    endif 

    call s:AddResultLine(s:CreateSmartMarkLine(a:element['filename'], search_line, 1, prompt))
endfunction

function! s:ShowList(list)
    for tag_element in a:list
        call s:ShowElement(tag_element)
    endfor
endfunction

function! s:ShowResult(list, mainnamespace)
    if empty(a:list)
        return
    endif

    let namespace_stack = []
    if a:mainnamespace != ''
       " call add(namespace_stack, a:mainnamespace)
    endif

    let whole_list_pos = 0
    while whole_list_pos < len(a:list)
        "echo "***** new namepsace"
        let namespace_list = s:SplitResultByNamespaces(a:list, whole_list_pos)
        let namespace = namespace_list[0]['namespace']
        let kind = namespace_list[0]['kind']

    
        while ! empty(namespace_stack)
            let last_namespace = namespace_stack[-1]

            if ! s:InNamespace(last_namespace, namespace) 
                call remove(namespace_stack, -1) 
                call s:AddResultLine('<<<')
                continue
            endif
            break
        endwhile

        if empty(namespace_stack)
            call s:AddResultLine('/ '.namespace.' /')
        endif

       " if namespace != a:mainnamespace
            call add(namespace_stack, namespace)
       " endif

        call s:AddResultLine('>>> '.s:PromptByKind(kind).' '.namespace)

        let kind_pos = 0
        while kind_pos < len(namespace_list)
            "echo "***** new kind"

            let kind_list = s:SplitResultByKind(namespace_list, kind_pos)
            let kind = kind_list[0]['kind']
            let new_name_space = kind_list[0]['newnamespace']

            let need_wrap = ! new_name_space && kind != 'e'
            if need_wrap 
                call s:AddResultLine('>>> '.s:PromptByKind(kind))
            endif

            call s:ShowList(sort(kind_list,'s:SortNamesInOrderFunction'))

            if need_wrap
                call s:AddResultLine('<<<')
            endif

            let kind_pos += len(kind_list)
        endwhile

        let whole_list_pos += len(namespace_list)
    endwhile

    for el in (namespace_stack)
        call s:AddResultLine('<<<')
    endfor
endfunction

function! s:SplitResultByField(list, begin, field_name)
    let first_pos = a:begin
    let last_pos = a:begin
    let first_name = a:list[first_pos][a:field_name]
    let list_len = len(a:list)

    for i in range(first_pos, list_len-1)
        let name = a:list[i][a:field_name]
        if name != first_name
            break
        endif
        let last_pos += 1
    endfor

    return a:list[first_pos : last_pos-1]
endfunction

function! s:SplitResultByNamespaces(list, begin)
    return s:SplitResultByField(a:list, a:begin, 'namespace')
endfunction

function! s:SplitResultByKind(list, begin)
    return s:SplitResultByField(a:list, a:begin, 'kind')
endfunction

function! s:GatherTagInfo(tag_regexp)
endfunction

function! s:AddTagInfoUnderCursor()
    let word = expand('<cword>')
    let word = '\<'.word.'\>'
    call s:AddTagInfo(word)
endfunction

function! s:AddTagInfo(tag_regexp)

    let pattern = a:tag_regexp
    
    if pattern == ''
        let pattern = expand('<cword>')
        let show_pattern = pattern
        let pattern = '\<'.pattern.'\>'
    endif
    let show_pattern = substitute( pattern, '[<\>]', "", "g" )

    if ! s:GoToLastScoBuffer()
        return
    endif
    let old_tags = &tags

    let s:ResultLineNumber = line('$')
    let first_result_line = s:ResultLineNumber

    call s:SetSettings()

    let &tags = s:sco_settings['tags_db']

    let result = taglist(pattern)

    let result = sort(result, 's:SortNamesInOrderFunction')

    for el in result
        let el = s:ExpandTagElement(el) 
        call s:ShowTagElement(el)
    endfor

    if empty(result)
        call s:ErrorMsg("Couldn't find \"".show_pattern."\" tag info")
    elseif len(result)>1
        call append(first_result_line, ">>>")
        call append(first_result_line, "tags: tag, ".show_pattern)
        call append(s:ResultLineNumber+2, "<<<")
    endif

    exec first_result_line+1
    normal zt
    exec first_result_line+2
    call s:FoldEnter(0)
    exec first_result_line+3

    let &tags = old_tags
endfunction

" add information about class or all classes as tree
function! s:AddClassInfo(class_name)
    if ! s:GoToLastScoBuffer()
        return
    endif
    let old_tags = &tags
    call s:CommentMsg('please wait')
    let s:ResultLineNumber = line('$')
    let first_result_line = s:ResultLineNumber

    call s:SetSettings()
    let &tags = s:sco_settings['tags_db']

    if a:class_name != ''
        let result = s:GatherClassInfo(a:class_name)
    els
        let result = s:GatherAllClasseInfo()
    endif

    if empty(result)
        call s:ErrorMsg('tag list empty')
        let &tags = old_tags
        return
    endif
    call sort(result, 's:SortElementsByNamespaceFunction2')
    call s:ShowResult(result, a:class_name)

    if first_result_line == s:ResultLineNumber
        if a:class_name != ''
            call s:ErrorMsg("couldn't find information about \"".a:class_name.'" class')
        else
            call s:ErrorMsg("couldn't find information about classes")
        endif
    elseif a:class_name == ''
        call append(first_result_line, '>>> Classes information')
        call append(s:ResultLineNumber, '<<<')
    endif
    call s:CommentMsg('done')

    let &tags = old_tags
endfunction

" save sco result
function! <SID>SaveResult() "{{{
	exec "w"
endfunction "}}}
" escape search pattern
function! <SID>EscapePattern(line) "{{{
	return escape(a:line,'.$^\*[]~')
endfunction "}}}

function! <SID>SaveBuffer()
    exec 'update'
endfunction

function! <SID>ErrorMsg(msg)
    echohl WarningMsg | echo a:msg | echohl None
endfunction

function! <SID>CommentMsg(msg)
    echohl Comment | echo a:msg | echohl None
endfunction

"wrap range of lines with >>> <<<
function! <SID>FoldWrap(first, last, ...)
    if a:first < 0 || a:first > line('$') || a:first > a:last || a:last < 0 || a:last > line('$')
	return
    endif

    if exists('a:1')
	let comment = a:1
    else
	let comment = input('Enter wrap comment:')
    endif

    call append(a:first-1, '>>>')
    call append(a:first-1, '/ '.comment.' /')
    call append(a:last+2, '<<<')
    exec ':'.a:first
endfunction

"change comment of smart makrs
function! <SID>SetCaption(...) "{{{
    if exists('a:1')
	let caption = a:1
    else
	let caption = ''
    endif

    let line = getline('.')

    if line !~ s:smart_mark_pattern_without_comment && line !~ s:smart_mark_pattern_comment
	call <SID>ErrorMsg('Captions only on smart marks')
	return
    endif

    let old_caption = ''
    let new_caption = caption
    if line =~ s:smart_mark_pattern
	if caption == ''
	    let old_caption = substitute(line, s:smart_mark_pattern, '\4', '')
	endif
    endif

    if caption == ''
	let new_caption = input('Enter mark caption:',old_caption)
	if new_caption == ''
	    let new_caption = 'No caption'
	endif
    endif

    if line =~ s:smart_mark_pattern_comment
	let line = substitute(line, s:smart_mark_pattern_comment, <SID>CreateCommentCaption(new_caption),'')
    else
	let line = line.<SID>CreateCommentCaption(new_caption)
    endif

    call setline(line('.'), line)
endfunction "}}}

function! s:SetFileNameCaption()
    let line = getline('.')

    if line !~ s:smart_mark_pattern_without_comment && line !~ s:smart_mark_pattern_comment
	call <SID>ErrorMsg('Captions only on smart marks')
	return
    endif

    let caption = "NoFileName?"
    if line =~ s:smart_mark_pattern
        let caption = <SID>EscapePattern(substitute(line, s:smart_mark_pattern, '\1', ''))
    endif

    if line =~ s:smart_mark_pattern_comment
	let line = substitute(line, s:smart_mark_pattern_comment, <SID>CreateCommentCaption(caption),'')
    else
	let line = line.<SID>CreateCommentCaption(caption)
    endif

    call setline(line('.'), line)
endfunction

" return how many times search pattern match (from the beginig of file)
function! <SID>Search(line_number) "{{{
	let l:pattern = getline(a:line_number)
	let l:pattern = <SID>EscapePattern(l:pattern)
	let l:pattern = '^'.l:pattern.'$'
	"echo "Pattern:".l:pattern
	exec ':0'
	let l:is_found = search(l:pattern,'c')
	if l:is_found == 0
		return 0
	endif

	let l:jump_count = 1
	while l:is_found != a:line_number
		let l:is_found = search(l:pattern,'')
		let l:jump_count = l:jump_count + 1
	endwhile

	"echo "jumps:".l:jump_count
	return l:jump_count
endfunction "}}}

" move to N'th pattern match 
function! <SID>JumpTo(pattern, jump_count) "{{{
	exec ':0'
	let l:flag = 'c'
	let l:completed_jumps = 0
	let l:pattern = '^'.a:pattern.'$'
	while l:completed_jumps < a:jump_count
		let l:line_number = search(l:pattern, l:flag)
		if l:line_number == 0
			return 0
		endif
		let l:completed_jumps = l:completed_jumps + 1
		let l:flag = ''
	endwhile
        return 1
endfunction "}}}

function! s:UnEscape(string, unescape_list)
    let result = ''
    for i in range(len(a:string)-1)
        if a:string[i] == '\' && matchstr(a:unescape_list, a:string[i+1]) != ''
            let i += 1
            continue
        endif
        let result .= a:string[i]
    endfor
    return result.a:string[-1:]
endfunction

function! s:JumpToHard(pattern, jumps_count)
    let pattern = s:EscapePattern(a:pattern)
    if ! s:JumpTo(pattern, a:jumps_count)
        let pattetn = a:pattern
        if ! s:JumpTo(pattern, a:jumps_count)
            let pattern = s:UnEscape(a:pattern, '/')
            let pattern = s:EscapePattern(pattern)
            if ! s:JumpTo(pattern, a:jumps_count)
                call s:ErrorMsg("Can't find pattern:".pattern) 
            endif
        endif
    endif
endfunction

" Parse sco settings (% option:value)
function! <SID>ParseSCOSettings() "{{{
	let l:line_count = line("$")
	let s:sco_settings = {}
	if l:line_count == 0 
		return 
	endif

	let l:line_number = 1
	while l:line_number <= l:line_count
		let l:line = getline(l:line_number)
		let l:option_pattern = '^%\s\(\S\+\):\s\(\S\+\)'
		"echo 'test:'.l:line_number.' :'.l:line
		if l:line =~ l:option_pattern
			"echo 'pattern_match'
			let l:option_name = substitute(l:line, l:option_pattern, '\1', '')
			let l:option_value = substitute(l:line, l:option_pattern, '\2', '')
			"echo "otpname:".l:option_name." ; value:".l:option_value
			let s:sco_settings[ l:option_name ] = l:option_value
		endif
		
		if l:line =~ '^\s*$'
			break
		endif

		let l:line_number = l:line_number + 1
	endwhile
endfunction "}}}

" Put default option settings to sco buffer if not present
function! <SID>DefaultSetting(name, value) "{{{
	if has_key(s:sco_settings, a:name)==0
		call append(0, '% '.a:name.': '.a:value)
		let s:sco_settings[a:name] = a:value
	endif
endfunction "}}}

" execute commands before execute command
function! s:ExecuteCommonCommand()
    let line_number = 1
    while line_number < line('$')
        let line = getline(line_number)

        if line =~ "^\s*$"
            break
        endif

        if line =~ "^% command_setup:"
            let command = s:FindCommand( line_number + 2 )
            if command != ""
                exec command
            endif
            return
        endif

        let line_number += 1
    endwhile
endfunction

" set all sco settings 
function! <SID>SetSettings() "{{{
	call <SID>ParseSCOSettings()
	call <SID>DefaultSetting('tags_db', g:sco_default_tags)
	call <SID>DefaultSetting('cscope_exe', g:sco_default_exe)
	call <SID>DefaultSetting('cscope_db', g:sco_default_db)
endfunction "}}}

" select next sco line to edit
function! s:SCODown()
    if ! s:GoToLastScoBuffer()
        return
    endif

    let line_number = line('.') + 1
    let last_line_number = line('$')
    let done = 0

    while line_number <= last_line_number
        if s:EditFileInLine(line_number)
            let done = 1
            break
        endif
        let line_number += 1
    endwhile

    if ! done
        call s:ErrorMsg('Last line reached')
    endif
endfunction

" select prev sco line to edit
function! s:SCOUp()
    if ! s:GoToLastScoBuffer()
        return
    endif

    let line_number = line('.') - 1
    let done = 0

    while line_number >= 0
        if s:EditFileInLine(line_number)
            let done = 1
            break
        endif
        let line_number -= 1
    endwhile

    if ! done
        call s:ErrorMsg('First line reached')
    endif
endfunction

function! s:SCONextBuffer( buffer_number )
    let current_buffer = a:buffer_number
    let buffers_count = bufnr('$')

    let i = current_buffer
    if current_buffer == s:last_sco_buffer
        let i = current_buffer + 1
    endif

    if i > buffers_count
        let i = 1
    endif

    while i <= buffers_count
        let buffer_name = bufname(i)
        if buffer_name =~ '\.sco$'
            return i
        endif

        let i += 1
    endwhile

    return 0
endfunction

" return previous sco buffer from list
function! s:SCOPreviousBuffer( buffer_number, return_last )
    let current_buffer = a:buffer_number

    let buffers_count = bufnr('$')
    
    let i = current_buffer
    if current_buffer == s:last_sco_buffer
        let i = current_buffer - 1
    else
        if a:return_last
            return s:last_sco_buffer
        endif
    endif

    if i < 1
        let i = buffers_count
    endif

    while i >= 1
        let buffer_name = bufname(i)
        if buffer_name =~ '\.sco$'
            return i
        endif
        let i -= 1
    endwhile

    return 0
endfunction

function! s:SCOSelectPreviousBuffer()
    let buffer_number = s:SCOPreviousBuffer( bufnr(''), 1 )
    if buffer_number == 0
        let buffer_number = s:SCOPreviousBuffer( bufnr('$'), 0 )
    endif

    if buffer_number == 0
        let buffer_number = s:last_sco_buffer
    endif

    exec 'buffer '.buffer_number
endfunction

function! s:SCOSelectNextBuffer()
    let buffer_number = s:SCONextBuffer( bufnr('') )
    if buffer_number == 0
        let buffer_number = s:SCONextBuffer( 1 )
    endif

    if buffer_number == 0
        let buffer_number = s:last_sco_buffer
    endif

    exec 'buffer '.buffer_number
endfunction

function! s:SavePreviousSearchAsMarks()
    let last_template = @/
    let file_name = expand("%:p")
    let current_line_number = line('.')


    let last_template_for_print = substitute( last_template, '[<\>]', "", "g" )
    let header_line = "header: searches for '".last_template_for_print."' in file: '".file_name."'"
    let tag_line = "  tags: search, ".last_template_for_print

    let match_number = -1
    let line_numbers = []
    call cursor(1, 1)
    let line_number = search(last_template, 'cW')
"    call cursor(line_number + 1, 1)
    let i = 0
    while line_number > 0
        if line_number != 0
            call add(line_numbers, line_number)
        endif

        if line_number == current_line_number
            let match_number = i
        endif

        let line_number = search(last_template, 'W')
        let i += 1
    endwhile

    let marks = []
    for line_number in line_numbers
        let markline = s:ReceiveSmartMarkLine( line_number )
        call add(marks, markline)
    endfor

    if ! s:GoToBufferToAppend()
        return
    endif

    call append( s:LineToAppend(1), header_line )
    call append( s:LineToAppend(1), tag_line )

    let block_start = s:LineToAppend(1)
    call append( block_start, '>>>' )
    for line in marks
        call append( s:LineToAppend(1), line )
    endfor
    call append( s:LineToAppend(1), '<<<' )

    exec block_start - 1
    normal zt
    exec block_start + 1
    call s:FoldEnter(0)
    if match_number != -1
        exec block_start + 2 + match_number
    endif

    normal zo
    normal zo
    normal zc

    nohlsearch

endfunction

function! s:EditFileInLine(line_number)
    exec ':'.a:line_number
    return s:EditFile(0)
endfunction

function! s:GoToScoBuffer( bufnumber )
	if bufnr('%') == a:bufnumber
	    return 1
	endif

        let bufnumber = a:bufnumber
        if bufnumber == -1
            let bufnumber = s:last_sco_buffer
        endif

	let l:last_sco_buffer_name = bufname( bufnumber )

	if l:last_sco_buffer_name !~ "sco$"
		call <SID>ErrorMsg('sco ['.bufnumber.'] buffer not present')
		return 0
	endif

	exec 'buffer '.bufnumber

	if bufnr('%') != bufnumber
	    call <SID>ErrorMsg("Can't open last sco buffer")
	    return 0
	endif
	return 1
endfunction

function! <SID>GoToBufferToAppend()
    return s:GoToScoBuffer( s:buffer_to_append )
endfunction
" open last sco buffer
function! <SID>GoToLastScoBuffer() "{{{
    return s:GoToScoBuffer( s:last_sco_buffer )
endfunction "}}}

" put results from cscope
function! <SID>CScopeResult(type, word) "{{{
	if ! <SID>GoToLastScoBuffer()
		return
	endif

	call <SID>SetSettings()
	let l:cmd_line = s:sco_settings['cscope_exe']
	let l:data_base = s:sco_settings['cscope_db']
	let l:cmd_line = l:cmd_line.' -d -L -'.a:type.' "'.a:word.'" -f '.l:data_base
	let l:request_line = s:sco_requests[ a:type ].' "'.a:word.'"'

	exec ':'.line("$")
	let l:first_line = line(".")
	exec 'r !'.l:cmd_line
	let l:last_line = line(".")

	if l:first_line == l:last_line
		call <SID>ErrorMsg(l:request_line.' not found in '.l:data_base)
		echo ""
		return
	endif
        let l:failed = append(l:first_line, 'tags: '.s:sco_requests[ a:type ].' ,'.a:word)
        let l:failed = append(l:first_line+1, '>>> ')
        let l:failed = append(l:last_line+2, '<<<')

	let l:first_line = l:first_line + 3
	let l:last_line = l:last_line + 2
	let l:line_number = l:first_line
	let l:max_file_name_length = 0
	let l:max_function_name_length = 0
	let l:max_line_number_length = 0

	let l:pattern = '^\(\S\+\)\s\(\S\+\)\s\(\d\+\)\s\(.*\)$'

	while l:line_number <= l:last_line
		let l:line = getline(l:line_number)

		let l:file_name = substitute(l:line, l:pattern, '\1', '')
		let l:function_name = substitute(l:line, l:pattern, '\2', '')
		let l:file_line_number = substitute(l:line, l:pattern, '\3', '')
		let l:body = substitute(l:line, l:pattern, '\4', '')

		if strlen(l:file_name) > l:max_file_name_length
			let l:max_file_name_length = strlen(l:file_name)
		endif

		if strlen(l:function_name) > l:max_function_name_length
			let l:max_function_name_length = strlen(l:function_name)
		endif

		if strlen(l:file_line_number) > l:max_line_number_length
			let l:max_line_number_length = strlen(l:file_line_number)
		endif

		let l:line_number = l:line_number + 1
	endwhile

	let l:line_number = l:first_line
	while l:line_number <= l:last_line
		let l:line = getline(l:line_number)

		let l:file_name = substitute(l:line, l:pattern, '\1', '')
		let l:function_name = substitute(l:line, l:pattern, '\2', '')
		let l:file_line_number = substitute(l:line, l:pattern, '\3', '')
		let l:body = substitute(l:line, l:pattern, '\4', '')

		let l:new_line = printf('# %-'.max_file_name_length.'s %'.max_function_name_length.'s %'.max_line_number_length.'s %s', l:file_name, l:function_name, l:file_line_number, l:body)
		call setline(l:line_number, l:new_line)

		let l:line_number = l:line_number + 1
	endwhile
	exec ':'.(l:first_line-2)
        normal zt
	exec ':'.(l:first_line-1)
        call s:FoldEnter(0)
	exec ':'.(l:first_line)
endfunction "}}}

" function get line number of open fold >>>
function! <SID>OpenFoldLineNumber() "{{{
	let l:first_line_num = -1
	let l:line_num = line('.')
	while l:line_num > 0
		let l:line = getline(l:line_num)
		if line =~ '^>>>'
			let l:first_line_num = l:line_num
			break
		endif
		let l:line_num = l:line_num - 1
	endwhile
	return l:first_line_num
endfunction "}}}

" function get line number of close fold <<<
function! <SID>CloseFoldLineNumber() "{{{
	let l:last_line_num = -1
	let l:line_num = line('.')
	let l:line_count = line('$')
	while l:line_num <= l:line_count
		let l:line = getline(l:line_num)
		if line =~ '^<<<'
			let l:last_line_num = l:line_num
			break
		endif
		let l:line_num = l:line_num + 1
	endwhile
	return l:last_line_num
endfunction "}}}

" allign folded result
function! <SID>AllignFoldResult() "{{{
	let l:first_line_num = <SID>OpenFoldLineNumber()
	let l:last_line_num = <SID>CloseFoldLineNumber()

	if l:first_line_num<0 || l:last_line_num<0
		return
	endif

	call <SID>AllignResult(l:first_line_num+1, l:last_line_num-1)
	call <SID>AllignResultNewMarks(l:first_line_num+1, l:last_line_num-1)
endfunction "}}}

" filter result inside >>> <<<
function! <SID>FilterResult(delete_pattern, leave_pattern) "{{{
	let l:first_line_num = <SID>OpenFoldLineNumber()
	let l:last_line_num = <SID>CloseFoldLineNumber()

	if l:first_line_num < 0 || l:last_line_num < 0
		return
	endif

	let l:line_num = l:first_line_num + 1
	while l:line_num < l:last_line_num
		let l:line = getline(l:line_num)

		if l:line =~ a:delete_pattern && l:line !~ a:leave_pattern
			exec l:line_num.'d'
			let l:line_num = l:line_num - 1
			let l:last_line_num = l:last_line_num - 1
		endif
		let l:line_num = l:line_num + 1
	endwhile
	call <SID>AllignFoldResult()
endfunction "}}}

" allign sco result
function! <SID>AllignResult(first_line, last_line) "{{{
	let l:pattern = '^#\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\d\+\)\s\+\(.*\)$'

	let l:max_file_name_length = 0
	let l:max_function_name_length = 0
	let l:max_line_number_length = 0

	let l:line_number = a:first_line
	while l:line_number <= a:last_line
		let l:line = getline(l:line_number)
		if l:line !~ l:pattern
			let l:line_number = l:line_number + 1
			continue
		endif

		let l:file_name = substitute(l:line, l:pattern, '\1', '')
		let l:function_name = substitute(l:line, l:pattern, '\2', '')
		let l:file_line_number = substitute(l:line, l:pattern, '\3', '')
		let l:body = substitute(l:line, l:pattern, '\4', '')

		if strlen(l:file_name) > l:max_file_name_length
			let l:max_file_name_length = strlen(l:file_name)
		endif

		if strlen(l:function_name) > l:max_function_name_length
			let l:max_function_name_length = strlen(l:function_name)
		endif

		if strlen(l:file_line_number) > l:max_line_number_length
			let l:max_line_number_length = strlen(l:file_line_number)
		endif

		let l:line_number = l:line_number + 1
	endwhile

	let l:line_number = a:first_line
	while l:line_number <= a:last_line
		let l:line = getline(l:line_number)
		if l:line !~ l:pattern
			let l:line_number = l:line_number + 1
			continue
		endif

		let l:file_name = substitute(l:line, l:pattern, '\1', '')
		let l:function_name = substitute(l:line, l:pattern, '\2', '')
		let l:file_line_number = substitute(l:line, l:pattern, '\3', '')
		let l:body = substitute(l:line, l:pattern, '\4', '')

		let l:new_line = printf('# %-'.max_file_name_length.'s %'.max_function_name_length.'s %'.max_line_number_length.'s %s', l:file_name, l:function_name, l:file_line_number, l:body)
		call setline(l:line_number, l:new_line)

		let l:line_number = l:line_number + 1
	endwhile
endfunction "}}}

" allign sco result (new marks format)
function! <SID>AllignResultNewMarks(first_line, last_line) "{{{
	let l:pattern = '^@\s\+\(\S\+\)\s\+\(\d\+\)\s\(.*\)$'

	let l:max_file_name_length = 0
	let l:max_repeat_count_length = 0

	let l:line_number = a:first_line
	while l:line_number <= a:last_line
		let l:line = getline(l:line_number)

		if l:line !~ l:pattern
			let l:line_number = l:line_number + 1
			continue
		endif

		let l:file_name = substitute(l:line, l:pattern, '\1', '')
		let l:repeat_count = substitute(l:line, l:pattern, '\2', '')

		if strlen(l:file_name) > l:max_file_name_length
			let l:max_file_name_length = strlen(l:file_name)
		endif

		if strlen(l:repeat_count) > l:max_repeat_count_length
			let l:max_repeat_count_length = strlen(l:repeat_count)
		endif

		let l:line_number = l:line_number + 1
	endwhile

	let l:line_number = a:first_line
	while l:line_number <= a:last_line
		let l:line = getline(l:line_number)
		if l:line !~ l:pattern
			let l:line_number = l:line_number + 1
			continue
		endif

		let l:file_name = substitute(l:line, l:pattern, '\1', '')
		let l:repeat_count = substitute(l:line, l:pattern, '\2', '')
		let l:search_pattern = substitute(l:line, l:pattern, '\3', '')

		let l:new_line = printf('@ %-'.max_file_name_length.'s %'.max_repeat_count_length.'s %s', l:file_name, l:repeat_count, l:search_pattern)
		call setline(l:line_number, l:new_line)

		let l:line_number = l:line_number + 1
	endwhile
endfunction "}}}

" allign reange
function! <SID>AllignAllInRange(first, last)
    if a:first < 0 || a:first > line('$') || a:first > a:last || a:last < 0 || a:last > line('$')
	return
    endif

    call <SID>AllignResult(a:first, a:last)
    call <SID>AllignResult(a:first, a:last)
endfunction!

" add mark from file
function! <SID>AddMark() "{{{
	let l:line_number = line('.')
	let l:line = getline('.')
	let l:file_name = expand('%:p')

	if ! <SID>GoToBufferToAppend()
		return
	endif


	let l:mark_line = '# '.l:file_name.' <mark> '.l:line_number.' '.l:line
        let line_to_append = s:LineToAppend(1)
	call append( line_to_append, l:mark_line)
        exec line_to_append + 1

	let l:line_number = line('$')
	while l:line_number >= 0
		let l:line = getline(l:line_number)
		if l:line !~ '<mark>'
			break
		endif
		let l:line_number = l:line_number - 1
	endwhile

	call <SID>AllignResult(l:line_number+1, line('$'))
endfunction "}}}

function! s:CreateSmartMarkLine(file_name, search_pattern, jumps_count, caption)
	let result = '@ '.a:file_name.' '.a:jumps_count.' '.a:search_pattern.<SID>CreateCommentCaption(a:caption)
        return result
endfunction

function! s:LineToAppend( increase )
    if s:line_to_append < 0 
        return line('$')
    endif
    
    let result = s:line_to_append
    if a:increase && s:line_to_append >= 0
        let s:line_to_append += 1
    endif

    return result
endfunction

function! <SID>SetCurrentLineAsLineToAppend()
    let line_number = line('.')
    let s:line_to_append = line_number-1
    let s:buffer_to_append = bufnr('')

    if line_number == line('$')
        let s:line_to_append = -1
    endif
endfunction

function! <SID>ReceiveSmartMarkLine( line_number )
        let line_number = a:line_number
	let line = getline( line_number )
	let file_name = expand('%:p')
	let jumps_count = <SID>Search(line('.'))

        let smart_mark_line = s:CreateSmartMarkLine(file_name, line, jumps_count, line)
        return smart_mark_line
endfunction

function! <SID>AddSmartMark( line_number ) "{{{
        let smart_mark_line = s:ReceiveSmartMarkLine( a:line_number )
	let file_name = expand('%:p')
	if ! <SID>GoToBufferToAppend()
		return
	endif


        let line_to_append = s:LineToAppend(1)
        call append( line_to_append, smart_mark_line)

        exec line_to_append + 1

        call s:SaveBuffer()
        exec "edit +".a:line_number." ".file_name
endfunction "}}}

function! <SID>IsScoBuffer()
    if (bufname("%") =~ '\.sco$')
        return 1
    endif

    return 0
endfunction

function! <SID>RemarkWithSmartMark()
        if <SID>IsScoBuffer()
            return
        endif

	let line = getline('.')
	let file_name = expand('%:p')
	let jumps_count = <SID>Search(line('.'))

	if ! <SID>GoToLastScoBuffer()
		return
	endif

        let smart_mark_line = s:CreateSmartMarkLine(file_name, line, jumps_count, line)
	call setline(line('.'), smart_mark_line)
endfunction

" make small addition to smart mark as comment
function! <SID>CreateCommentCaption(text) "{{{
    return ' ```'.a:text.'>>><<<'
endfunction "}}}

" open marks and resul lines in new tab with splitted windows
function! s:MultiOpen(lines_numbers)
    exec "tabnew"

    let vertical_split = 1
    let win_number = winnr()
    let line_processed = 1
    for item in a:lines_numbers
        if line_processed != len(a:lines_numbers)
            let line_processed += 1
            let win_number += 2
            exec "wincmd w"
            exec "wincmd w"

            if &buftype == "nofile"
                exec "wincmd w"
                let win_number += 1
            endif

            if win_number > winnr('$')
                let win_number = winnr()
                let vertical_split = ! vertical_split
            endif

            if vertical_split
                exec "vnew"
            else
                exec "new"
            endif

        endif
    endfor

    let item_number = 1

    for item in a:lines_numbers

        exec item_number." wincmd w"
        if ! s:GoToLastScoBuffer()
            return
        endif
        if ( s:EditFileInLine(item) )
        endif

        let item_number += 1
    endfor

endfunction

function! <SID>TransferCurrentToSmartMark()
    return <SID>TransferToSmartMark( line('.') )
endfunction

function! <SID>TransferToSmartMarkImpl( line_number, prefix )
    exec a:line_number

    let line = getline( a:line_number )
    let pattern = '^'.a:prefix.'\(\S\+\)\s*[:+ ]\s*\(\d\+\)\s*$'

    if line !~ pattern
        return 0
    endif

    let file_name = substitute(line, pattern, '\1', '')
    let line_number = substitute(line, pattern, '\2', '')

    exec "edit ".file_name
    exec line_number

    call <SID>RemarkWithSmartMark()

    return 1
endfunction

function! <SID>TransferToSmartMark( line_number )
    call <SID>SaveBuffer()
    
    if ! <SID>TransferToSmartMarkImpl( a:line_number, '' )
        if ! <SID>TransferToSmartMarkImpl( a:line_number, '.*at\s\+' )
            call <SID>ErrorMsg("invalid pattern: should be [at ]file_name[+: ]line_number")
            return 0
        endif
    endif

    return 1
endfunction

function! <SID>TransferRegionToSmartMarks( top, bottom )
    for i in range(a:top, a:bottom)
        call <SID>TransferToSmartMark( i )
    endfor
endfunction

function! s:MultiOpenRange(top, bottom)
    let lines_numbers = []
    for i in range(a:top, a:bottom)
        call add(lines_numbers, i)
    endfor

    call s:MultiOpen(lines_numbers)
endfunction


" search 
" [ vim expr ] 
" line from given line number to up of file
" return vim expr
function! s:FindCommand( start_line_number )
    let single_pattern = '^*\(.*\)$'
    let multi_pattern = '>>>.*\n{\n\(\s\+.*\n\)*}\n<<<'
    let line_number = a:start_line_number 

    let save_cursor = getpos(".")

    call cursor(line_number, 1)

    let multi_result_line_number = search(multi_pattern, 'ncWb')
    let single_result_line_number = search(single_pattern, 'ncWb')
    let empty_result_line_number = search('^\s*$', 'ncWb')

    if empty_result_line_number > multi_result_line_number && empty_result_line_number > single_result_line_number
        call setpos('.', save_cursor)
        return ''
    endif

    if single_result_line_number > multi_result_line_number 
        call setpos('.', save_cursor)
        return substitute(getline(single_result_line_number), single_pattern, '\1', '')
    endif

    if multi_result_line_number > single_result_line_number
        let line_number = multi_result_line_number + 2
        let result = ""
        while line_number < line('$')
            let line = getline(line_number)
            if line =~ '^}'
                break
            endif

            let result .= line."\n"
            let line_number += 1 
        endwhile


        call setpos('.', save_cursor)
        return result
    endif

    call setpos('.', save_cursor)
    return ''
endfunction

" substitute in [ vim expr ] command
" _pattern_ with search pattern of smart mark
" _file_ with file name
" _caption_ with caption of smart mark
function! s:CommandSubstituteParamteres( command, smart_line )
    let result = a:command

    let pattern = s:smart_mark_pattern_without_comment
    if a:smart_line =~ s:smart_mark_pattern
        let pattern = s:smart_mark_pattern
    endif

    let file_name = substitute(a:smart_line, pattern, '\1', '')
    let repeat_count = substitute(a:smart_line, pattern, '\2', '')
    let search_pattern = substitute(a:smart_line, pattern, '\3', '')
    let comment = substitute(a:smart_line, pattern, '\4', '')

    let result = substitute(result, '_pattern_', search_pattern, 'g')
    let result = substitute(result, '_file_', file_name, 'g')
    let result = substitute(result, '_caption_', comment, 'g')

    return result
endfunction

" select file to edit
" if force_open then ignore command presence
function! <SID>EditFile(force_open) "{{{
        let line_number = line('.')
	let l:current_line = getline(line_number)

	" like help tag marks
	if l:current_line =~ s:smart_mark_pattern
	    call <SID>SaveBuffer()
	    if s:preview
		    exec 'pclose'
	    endif

            let command_to_exec = ""

            " execute [vim expr] command if any
            if a:force_open == 0
                let command_to_exec = s:FindCommand(line_number)
            endif

"            echo command_to_exec
            if command_to_exec != ""
                call s:ExecuteCommonCommand()
                let substituted_command = s:CommandSubstituteParamteres(command_to_exec, l:current_line)
                let commands = split(substituted_command, '\n')

                for one_command in commands
                    try
                        exec one_command
                    catch /.*/
                        echo "command: '".one_command."' failed"
                    endtry
                endfor
                return 1
            endif


            " open smart mark
	    let file_name = substitute(l:current_line, s:smart_mark_pattern, '\1', '')
	    let jumps_count = substitute(l:current_line, s:smart_mark_pattern, '\2', '')
	    if jumps_count == ''
		let jumps_count = 1
	    endif

	    let pattern = substitute(l:current_line, s:smart_mark_pattern, '\3', '')

	    exec 'edit '.file_name
	    call <SID>JumpToHard(pattern, jumps_count)
	    return 1
	endif

	let l:pattern = '^#\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\d\+\)\s\+\(.*\)$'
	if l:current_line =~ l:pattern
	    call <SID>SaveBuffer()
	    let l:file_name = substitute(l:current_line, l:pattern, '\1','')
	    let l:line_number = substitute(l:current_line, l:pattern, '\3','')

	    if s:preview
		    exec 'pclose'
	    endif
	    exec 'edit  +:'.l:line_number.' '.l:file_name
	    return 1
	endif

        return 0
endfunction "}}}

" open fold or edit file
" if force_open then ignore command presence
function! <SID>FoldEnter(force_open) "{{{
    let line = getline('.')
    if (matchstr(line, '^>>>') != '')
	exec line('.').'foldopen'
	return
    endif

    call <SID>EditFile(a:force_open)
endfunction "}}}

" cursor move handler
function! <SID>Cursor_move_handler() "{{{
	if ! s:preview
		return
	endif

	let l:pattern = '^#\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\d\+\)\s\+\(.*\)$'
	let l:current_line = getline('.')

	if l:current_line =~ l:pattern
		let l:file_name = substitute(l:current_line, l:pattern, '\1', '')
		let l:line_number = substitute(l:current_line, l:pattern, '\3', '')
		exec 'pedit +'.l:line_number.' '.l:file_name
	else
		exec 'pclose'
	endif
endfunction "}}}

" toggle preview
function! <SID>TogglePreview() "{{{
	if s:preview
		let s:preview = 0
		exec 'pclose'
		return
	endif

	if ! s:preview
		let s:preview = 1
		call <SID>Cursor_move_handler()
		return
	endif
endfunction "}}}

" put help to sco buffer
function! <SID>AddHelpLines() "{{{
	let l:help_lines = []
	call add(l:help_lines, '/ press <Enter> to open help /')
	call add(l:help_lines, '>>> sco help')
	call add(l:help_lines, '/Hot keys local to this buffer:/')
	call add(l:help_lines, 'you can change them in sco_keys.vim file')
	call add(l:help_lines, '[normal] <CR> - select file to edit from result or open fold')
	call add(l:help_lines, '[normal] c<Space>p - Toggle preview mode')
	call add(l:help_lines, '[normal] c<Space>a - Allign folded result')
	call add(l:help_lines, '[visual] w - Wrap selected lines with > > >    < < <')
	call add(l:help_lines, '[visual] a - Allign selceted lines')
	call add(l:help_lines, '[visual] o - Open selected lines')
	call add(l:help_lines, '/Global hot keys:/')
	call add(l:help_lines, 'you can change them in sco_keys.vim file')
	call add(l:help_lines, 'c<Space>g - Find Global Definition of symbol under cursor')
	call add(l:help_lines, 'c<Space>c - Find C Symbol')
	call add(l:help_lines, 'c<Space>f - Find File')
	call add(l:help_lines, 'c<Space>i - Find Files including this file')
	call add(l:help_lines, 'c<Space>w - Find Functions calling this function')
	call add(l:help_lines, 'c<Space>t - Find tag')
	call add(l:help_lines, 'c<Space>s - store all lines with last search pattern to sco buffer as marks')
	call add(l:help_lines, 'c<Space>b - Open last sco buffer')
	call add(l:help_lines, 'c<Space>m - Mark current line')
	call add(l:help_lines, 'c<Space>n - Mark smart current line')
	call add(l:help_lines, 'c<Space>r - ReMark: Change current line in sco file to smart mark')
	call add(l:help_lines, '/Commands local to this buffer:/')
	call add(l:help_lines, ":Delete 'pattern' - delete all rows which match 'pattern' inside folded result")
	call add(l:help_lines, ":Leave 'pattern' - leave only rows which match 'pattern' inside folded result")
	call add(l:help_lines, ":Filter 'delete_pattern', 'leave_pattern' - leave only rows which match 'pattern' inside folded result and delete rows with 'delete_pattern'")
	call add(l:help_lines, ':Preview - toggle preview mode')
	call add(l:help_lines, ':Command - add multi line command pattern')
	call add(l:help_lines, ':AllignFold - allign lines inside  > > >   < < <')
	call add(l:help_lines, ':[range]AllignRange - allign lines in range')
	call add(l:help_lines, ':[range]MultiOpen - open marks in ranger in splitted windows')
	call add(l:help_lines, ":Caption ['new_caption'] - change or set caption of smart marks")
	call add(l:help_lines, ":FileNameCaption - change caption of smart marks to file name where marks are point")
	call add(l:help_lines, ":AppendPlace - change place where new marks will be appended")
	call add(l:help_lines, "\:[range]Wrap ['fold comment'] - wrap range of lines with  > > >   < < < ")
	call add(l:help_lines, "\:[range]TransferToMarks - convert lines '[at ]file_name[ :+]line_number' to smart mark. Useful for work with backtrace for example")
	call add(l:help_lines, '/Global commands:/')
	call add(l:help_lines, ":SCOClassInfo 'class[struct|enum]name' - add information about class(struct, enum). Tested on c++. (Using tags. Tags must be builded with ctags --fields=fks (default settings))")
	call add(l:help_lines, ":SCOClassInfo '' - add information about all classes, structures, enums")
	call add(l:help_lines, ":SCOTag 'pattern' - add information about tags")
	call add(l:help_lines, ":SCOTag '' - add information about tag under cursor")
	call add(l:help_lines, ":SCOSymbol 'symbolname' - find C Symbol")
	call add(l:help_lines, ":SCOGlobal 'functionname' - find Global definition")
	call add(l:help_lines, ":SCOFile 'filename' - find file")
	call add(l:help_lines, ":SCOInclude 'filename' - find files including <filename>")
	call add(l:help_lines, ":SCOWhoCall 'functionname' - find functions calling <functionname> function")
	call add(l:help_lines, ":SCOText 'text' - find text")
	call add(l:help_lines, ":SCOGrep 'pattern' - find grep pattern")
	call add(l:help_lines, ":SCOSaveSearch - store all lines with last search pattern to sco buffer as marks")
	call add(l:help_lines, ":SCOBuffer - go to last sco buffer")
	call add(l:help_lines, ":SCOMark - mark current line")
	call add(l:help_lines, ":SCOMarkSmart - mark smart current line")
	call add(l:help_lines, ":SCOReMark - ReMark: Change current line in sco file to smart mark")
	call add(l:help_lines, ":SCOUp - go to the previous mark ( or resultant line ) from last sco")
	call add(l:help_lines, ":SCODown - go to the next mark ( or resultant line ) from last sco")
	call add(l:help_lines, ":SCOPrevious - open previous sco buffer")
	call add(l:help_lines, ":SCONext - open next sco buffer")
	call add(l:help_lines, ":SCOPrevious nad :SCONext useful when you have for example following sco files:")
	call add(l:help_lines, "interfaces.sco; todo.sco; bugmarks.sco; breakpoints.sco; mychanges.sco")
	call add(l:help_lines, "/Format of mark/")
	call add(l:help_lines, "# filename functionname linenumber body")
	call add(l:help_lines, "/Format of smart mark/")
	call add(l:help_lines, "@ filename jumpscount pattern")
	call add(l:help_lines, "/jumpscount/")
	call add(l:help_lines, "if you have in text two patterns '^  return ERROR_CODE$' and mark second of them")
	call add(l:help_lines, "then jumpscount will be equal 2")
	call add(l:help_lines, "<<<")
	call append(line('$'), l:help_lines)
endfunction "}}}

function! <SID>SetScoFoldOptions()
    let s:old_fold_open = &foldopen
    let s:old_fold_close = &foldclose
    let s:old_fill_chars = &fillchars 
    highlight! link OldFolded Folded

    let &foldopen=''
    let &foldclose='all'
    let &fillchars=&fillchars.',fold: '

    highlight! link Folded String
endfunction

function! <SID>EnterScoBuffer() "{{{
	let s:last_sco_buffer = bufnr('%')
	call <SID>Cursor_move_handler()
	call <SID>SetScoFoldOptions()
endfunction "}}}

function! <SID>LeaveScoBuffer() "{{{
    let &foldopen = s:old_fold_open
    let &foldclose = s:old_fold_close
    let &fillchars = s:old_fill_chars
    highlight! link Folded OldFolded
endfunction "}}}

" change foldet text to sco format
function! ScoFoldText() "{{{
    let line = getline(v:foldstart)
    let comment_text = substitute(line, s:smart_mark_pattern, '\4', '')
    let pattern = '^\(.*\)>$'
    let comment_text = substitute(comment_text, s:smart_mark_pattern, '\1', '')
    let comment_text = substitute(comment_text, '^\t\+', '', '')
    let comment_text = substitute(comment_text, '^\s\+', '', '')


    if (matchstr(line, '^>>>') != '')

	let comment_text = substitute(comment_text, '^>>>', '', '')

        let line_number = v:foldstart
        let is_command = 0
        " vim command
        if getline(line_number + 1) =~ '{' 
            let comment_text = "<command>:".comment_text
            let is_command = 1
        endif

	let folded_lines_count = (v:foldend - v:foldstart) - 1
	let count_info = ' ]'
	if folded_lines_count > 1 
	    let count_info = ' '.folded_lines_count.' ]'
	endif
        if is_command
            let comment_text = "[ +".(folded_lines_count-2)." ] ".comment_text
        else
            let comment_text = "[ +".count_info.comment_text
        endif
    else
	let comment_text = "| ".comment_text. " |"
    endif

    let space_count = v:foldlevel
    while space_count > 1
	let comment_text = "    ".comment_text
	let space_count = space_count - 1
    endwhile
    return comment_text
endfunction "}}}

" set highlight and commands - called when .sco file readed
function! <SID>Prepare_sco_settings() "{{{
        call s:ExecuteCommonCommand()
	setlocal filetype=sco
	setlocal cursorline

	setlocal foldtext=ScoFoldText()
	setlocal foldmethod=marker
	setlocal foldmarker=>>>,<<<

	setlocal foldminlines=0

	let s:last_sco_buffer = bufnr('%')

	command! -nargs=1 SCOSymbol call <SID>CScopeResult(0, <args>)
	command! -nargs=1 SCOGlobal call <SID>CScopeResult(1, <args>)
	command! -nargs=1 SCOWhoCall call <SID>CScopeResult(4, <args>)
	command! -nargs=1 SCOText call <SID>CScopeResult(5, <args>)
	command! -nargs=1 SCOGrep call <SID>CScopeResult(6, <args>)
	command! -nargs=1 SCOFile call <SID>CScopeResult(7, <args>)
	command! -nargs=1 SCOInclude call <SID>CScopeResult(8, <args>)
        command! -nargs=1 SCOClassInfo call s:AddClassInfo(<args>)
        command! -nargs=1 SCOTag call s:AddTagInfo(<args>)
        command! SCOSaveSearch call s:SavePreviousSearchAsMarks()
	command! SCOBuffer call <SID>GoToLastScoBuffer()
	command! SCOMark call <SID>AddMark()
	command! -range SCOMarkSmart call <SID>AddSmartMark(<line1>)
	command! SCOReMark call <SID>RemarkWithSmartMark()
        command! SCODown call s:SCODown()
        command! SCOUp call s:SCOUp()
        command! SCOPrevious call s:SCOSelectPreviousBuffer()
        command! SCONext call s:SCOSelectNextBuffer()
        command! -buffer Enter call <SID>FoldEnter(0)
        command! -buffer ForceEnter call <SID>FoldEnter(1)
	command! -buffer Preview call <SID>TogglePreview()
	command! -buffer AllignFold call <SID>AllignFoldResult()
	command! -buffer -range AllignRange call <SID>AllignAllInRange(<line1>, <line2>)
	command! -buffer Caption call <SID>SetCaption('')
	command! -buffer FileNameCaption call <SID>SetFileNameCaption()
	command! -buffer AppendPlace call <SID>SetCurrentLineAsLineToAppend()
	command! -buffer -nargs=* -range Wrap call <SID>FoldWrap(<line1>, <line2>, <args>)
	command! -buffer -nargs=* -range MultiOpen call s:MultiOpenRange(<line1>, <line2>)
	command! -buffer -nargs=* Caption call <SID>SetCaption(<args>)
	command! -buffer -nargs=1 Delete call <SID>FilterResult(<args>, '$^')
	command! -buffer -nargs=1 Leave call <SID>FilterResult('.*', <args>)
	command! -buffer -nargs=1 -nargs=1 -complete=tag Filter call <SID>FilterResult(<args>)
	command! -buffer -nargs=* -range TransferToMarks call s:TransferRegionToSmartMarks(<line1>, <line2>)
        command! -buffer Command call append(line('.') - 1, ['>>>', '{', '    echo "command"','}', '<<<'])

        let g:sco_include_key_mappings = 1

        try
            runtime plugin/sco_keys.vim
        catch /.*/
            call <SID>ErrorMsg("can't find sco_keys.vim")
        finally
        endtry



	syn match sco_header /^% cscope_db: / nextgroup=sco_header_param
	syn match sco_header /^% cscope_exe: / nextgroup=sco_header_param
	syn match sco_header /^% tags_db: / nextgroup=sco_header_param
        syn match sco_header /^% command_setup:/ 
	syn match sco_comment /^\/.\+\/$/

	syn match sco_header_param /.*/ contained
	syn match sco  />>>.*$/
	syn match sco0 /<<<.*$/
	syn match sco1 /^#/ nextgroup=sco2 skipwhite
	syn match sco2 /\s\S\+/ nextgroup=sco3 contained skipwhite
	syn match sco3 /\s\S\+/ nextgroup=sco4 contained skipwhite
	syn match sco4 /\s\S\+/ nextgroup=sco5 contained skipwhite
	syn region sco5 start="\s" end="$" contains=Comment,Number,Float contained keepend

	syn match mark1 /^@/ nextgroup=mark2 skipwhite
	syn match mark2 /\s\S\+/ nextgroup=mark3 contained skipwhite
	syn match mark3 /\s\S\+/ nextgroup=mark4 contained skipwhite
	syn region mark4 start='\s' end='$' contained 

        syn match tags_header /^\s*tags:/ nextgroup=tags_list
        syn match tags_header_header /^header:/ nextgroup=tags_header_text
        syn match tags_header_text /.*/ contained
        syn match tags_list /\s*\w\+\s*/ nextgroup=tags_separator contained
        syn match tags_separator /,/ nextgroup=tags_list contained

        hi link tags_header         Type
        hi link tags_header_header  Type
        hi link tags_header_text  Special
        hi link tags_list       Comment
        hi link tags_separator  String

	hi link sco_header	Define
	hi link sco_header_param   Identifier
	hi link sco_comment     Comment
	hi link sco	 	Comment
	hi link sco0	 	Comment
	hi link sco1		Comment
	hi link sco2		Conditional
	hi link sco3		Identifier
	hi link sco4		Underlined
	hi link sco5		String

	hi link mark1	Comment
	hi link mark2	Statement
	hi link mark3	Special
	hi link mark4  	String

        " command [ vim expr ]  highlight
"        runtime! syntax/vim.vim
"        unlet b:current_syntax
        syn include @Vim syntax/vim.vim
        syn keyword scoCommandVariable _file_ _pattern_ _caption_ contained
        hi link scoCommandVariable Identifier

        syn match scoCommand /^\*.*$/ contains=scoCommandVariable,@Vim
        hi link scoCommand Identifier

"        syn region scoCommandsSetup start='^>>> % command_setup\s*\n*{' end='}$' contains=@Vim,sco_header
"        hi link scoCommandsSetup Define

        syn match scoMultiLineCommandStart />>>.*\n{/ nextgroup=scoMultiLineCommand,scoMultiLineCommandEnd skipnl
        syn match scoMultiLineCommand /\s\+.*$/ contains=scoCommandVariable,@Vim nextgroup=scoMultiLineCommand,scoMultiLineCommandEnd contained skipnl
        syn match scoMultiLineCommandEnd /}\n<<<.*/ contained 

        hi link scoMultiLineCommandStart Structure
        hi link scoMultiLineCommandEnd Structure

endfunction "}}}

" set highlight and commands, put help - called when .sco file created
function! <SID>Prepare_sco_settings_new_file()
	call <SID>Prepare_sco_settings()
        call s:SetSettings()
	call <SID>AddHelpLines()

        let sco_common_command = []
        call add(sco_common_command, '% command_setup:')
        call add(sco_common_command, '>>> common commands')
        call add(sco_common_command, '{')
        if ! exists('g:sco_default_common_command')
            let g:sco_default_common_command = [ 'echo "put vim commands in % command_setup: section"',
                        \ 'echo "it is the same as separate vimrc for everyproject and event more flexible"',
                        \ 'echo "put |let g:sco_default_common_command = [\"command1\", \"command2\",..]| in your .vimrc file "' ]
        endif
        for one_command in g:sco_default_common_command
            call add(sco_common_command, '    '.one_command)
        endfor
        call add(sco_common_command, '}')
        call add(sco_common_command, '<<<')
        call append(0, sco_common_command)
endfunction

augroup SourceCodeObedience
au! BufRead *.sco call <SID>Prepare_sco_settings()
au! BufNewFile *.sco call <SID>Prepare_sco_settings_new_file()
"au! WinEnter *.sco call <SID>EnterScoBuffer()
"au! WinLeave *.sco call <SID>LeaveScoBuffer()
au! BufEnter *.sco call <SID>EnterScoBuffer()
au! BufLeave *.sco call <SID>LeaveScoBuffer()
au! CursorMoved *.sco nested call <SID>Cursor_move_handler()
augroup END
" vim:ft=vim:fdm=marker:ff=unix:nowrap
