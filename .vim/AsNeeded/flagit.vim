" FlagIt
" 2006-06-21, Paul Rouget <paul.rouget@no-log.org>
"
" Thanks to Brian Wang's VisualMark.vim: http://www.vim.org/scripts/script.php?script_id=1026
"
" ---------------------------------------------------------------------
" Version: 0.1
"
" Description:
" FlagIt privides a simple way to flag lines with a set of signs
"
" Installation:
" Drop it into your plugin directory
"
" Usage:
" g:Fi_Flags
" 	a dictionnary which describes the flags
"		Synopsis:
"		an item: '"flagName" : ["aUrlToTheImagePath", "aText, One or two character", uniq, "additionnal options"]'
"
"		"flagName" : an uniq identifier
"		"aUrlToTheImagePath" : The path to a pixmap. The flag will be drawn as a pixmap (if GUI avaible and g:Fi_OnlyText is 0).
"		"aText" : One or two character. The flag will be drawn as a text (if GUI not avaible or g:Fi_OnlyText is 1)
"		uniq : If 1, only one instance of this flag will be drawn, else multiple instance will be allowed
"		"additionnal options" : options added to signs definition (cf. "sign define")
"
" 	example:
"			let g:Fi_Flags = {"fixme" : ["/home/login/.vim/signs/fixme.png", "!!", 0, ""],
"			\ "error" : ["/home/login/.vim/signs/error.png", "XX", 1, "texthl=ErrorMsg linehl=ErrorMsg"] }
"
" g:Fi_ShowMenu
" 	If 1 and Gui avaible and g:Fi_OnlyText is 0, a menu will be added to the ToolBar.
"
"	g:Fi_OnlyText
"		If 1, pixmap will not be used
"
"	FlagList
"		List all avaible flags
"
"	FlagIt flagName [line number]
"		Add a flag. If line number is not provided, current line is uses
"		Il a flag is already presents, it will be removed
"
"	UnFlag [flagName]
"		Remove all flags of type flagName
"		If flagName is not provided,  remove all flags
"	
" FlagDemo
" 	Just a way to draw all kind of flags (for test)
"
" TODO:
" save flags (Modelines ? session ? dedicated file ?)
"
" Example:
" my vimrc:
" ----
"map <F1> :FlagIt arrow<CR>
"map <F2> :FlagIt function<CR>
"map <F3> :FlagIt warning<CR>
"map <F4> :FlagIt error<CR>
"map <F5> :FlagIt step<CR>
"                                                                                                                                                                                                                                                 
"map <C-F1> :UnFlag arrow<CR>
"map <C-F2> :UnFlag function<CR>
"map <C-F3> :UnFlag warning<CR>
"map <C-F4> :UnFlag error<CR>
"map <C-F5> :UnFlag step<CR>
"                                                                                                                                                                                                                                                 
"map <F8> :UnFlag<CR>
"
"let icons_path = "/home/paul/.vim/signs/"
"let g:Fi_Flags = { "arrow" : [icons_path."16.png", "> ", 1, "texthl=Title"],
"			\ "function" : [icons_path."17.png", "+ ", 0, "texthl=Comment"],
"			\ "warning" : [icons_path."8.png", "! ", 0, "texthl=WarningMsg"],
"			\ "error" : [icons_path."4.png", "XX", "true", "texthl=ErrorMsg linehl=ErrorMsg"],
"			\ "step" : [icons_path."5.png", "..", "true", ""] }
"let g:Fi_OnlyText = 0
"let g:Fi_ShowMenu = 1
" ----


" ---------------------------------------------------------------------
" Load Once: 
if &cp || exists("g:loaded_flagit")
 finish
endif
let g:loaded_flagit = 1

" ---------------------------------------------------------------------
" Public Command:

command! -nargs=+ FlagIt :call s:FlagALine(<f-args>)
command! -nargs=* UnFlag :call s:UnFlag(<f-args>)
command! FlagDemo :call FlagDemo()
command! FlagList :call FlagList()


" ---------------------------------------------------------------------
" Public Variable:

if !exists('g:Fi_ShowMenu')
	let g:Fi_ShowMenu = 0
endif
if !exists('g:Fi_OnlyText')
	let g:Fi_OnlyText = 1
endif
if !exists('g:Fi_Flags')
	let g:Fi_Flags = {}
endif

" ---------------------------------------------------------------------
" Add signs:

let tbItem = 1
for key in keys(g:Fi_Flags)
	if has("gui_running") && !g:Fi_OnlyText
		exe ":sign define ".key." icon=".g:Fi_Flags[key][0]." ".g:Fi_Flags[key][3]
		if g:Fi_ShowMenu
			exe ':menu icon='.g:Fi_Flags[key][0].' ToolBar.flag'.tbItem.' :FlagIt '.key.'<CR>'
			let tbItem += 1
		endif
	else
		exe ":sign define ".key." text=".g:Fi_Flags[key][1]." ".g:Fi_Flags[key][3]
	endif
endfor

let s:Fi_FlagId = 1

" ---------------------------------------------------------------------
" List all signs:

fun! FlagList()
	for key in keys(g:Fi_Flags)
		echo key
	endfor
endfunction

" ---------------------------------------------------------------------
" Add flags i to line i, just for test:

fun! FlagDemo()
	let line = 1
	for key in keys(g:Fi_Flags)
		:call s:FlagALine(key, line)
		let line += 1
	endfor
endfunction

" ---------------------------------------------------------------------
" Flag a line:

fun! s:FlagALine(flag, ...)
	if a:0 == 0
		"if no line specified, use current line
		let a:line = line(".")
	else
		let a:line = a:1
	endif

	let sign_list = GetVimCmdOutput('sign place buffer=' . winbufnr(0))

	let aFlagId = s:Fi_get_flagid_from_line(sign_list, a:line)
	if aFlagId != ""
		exe ':sign unplace '.aFlagId.' buffer=' . winbufnr(0)
		return
	endif

	let aFlagId = ""
	if g:Fi_Flags[a:flag][2]
		let aFlagId = s:Fi_get_flagid_from_flag(sign_list, a:flag)
	endif
	exe ':sign place '.s:Fi_FlagId.' line='.a:line.' name='.a:flag.' buffer=' . winbufnr(0)
	let s:Fi_FlagId += 1
	if aFlagId != ""
		exe ':sign unplace '.aFlagId.' buffer=' . winbufnr(0)
	endif
endfun

" ---------------------------------------------------------------------
" Remove flags:

fun! s:UnFlag(...)
	if a:0 == 0
		for key in keys(g:Fi_Flags)
			:call s:UnFlag(key)
		endfor
	else
		while 1
			let sign_list = GetVimCmdOutput('sign place buffer=' . winbufnr(0))
			let aFlagId = s:Fi_get_flagid_from_flag(sign_list, a:1)
			if aFlagId == ""
				break
			endif
			exe ':sign unplace '.aFlagId.' buffer=' . winbufnr(0)
		endwhile
	endif
endfun

" ---------------------------------------------------------------------
" Get flagId from a flag name:

fun! s:Fi_get_flagid_from_flag(string, flag)
	let tmp = 0
	while 1
		let line_str_index = -1
		let line_str_index = match(a:string, "name=", tmp)
		if line_str_index <= 0
			return ""
		endif
		let equal_sign_index = match(a:string, "=", line_str_index)
		let space_index      = match(a:string, "\n", equal_sign_index)
		let flag_name = strpart(a:string, equal_sign_index + 1, space_index - equal_sign_index - 1)
		if flag_name == a:flag
			let line_str_index = match(a:string, "id=", tmp)
			let equal_sign_index = match(a:string, "=", line_str_index)
			let space_index      = match(a:string, " ", equal_sign_index)
			let flagId = strpart(a:string, equal_sign_index + 1, space_index - equal_sign_index - 1)
			return flagId
		endif
		let tmp = space_index
	endwhile
	return ""
endfun

" ---------------------------------------------------------------------
" Get flagId from a line number:

fun! s:Fi_get_flagid_from_line(string, line)
	let tmp = 0
	while 1
		let line_str_index = -1
		let line_str_index = match(a:string, "line=", tmp)
		if line_str_index <= 0
			return ""
		endif
		let equal_sign_index = match(a:string, "=", line_str_index)
		let space_index      = match(a:string, " ", equal_sign_index)
		let line_nb = strpart(a:string, equal_sign_index + 1, space_index - equal_sign_index - 1)
		if line_nb == a:line
			let line_str_index = match(a:string, "id=", space_index)
			let equal_sign_index = match(a:string, "=", line_str_index)
			let space_index      = match(a:string, " ", equal_sign_index)
			let flagId = strpart(a:string, equal_sign_index + 1, space_index - equal_sign_index - 1)
			return flagId
		endif
		let tmp = space_index
	endwhile
	return ""
endfun

