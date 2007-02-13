" menu-n.vim: (global plugin) expands the menu
" Last Change:	2004-12-30
" Maintainer:	J. Behrens   <jochen@behrens-nms.de>
" Version:	0.9

" vim is a very powerfull editor with tons of functions and even 
" more documentation. I always found new functions and i was looking
" for a way to search them quickly. index.txt was my friend so far :)

" Sometime I have my little daughter laying in my arm and I have only 
" one hand for writing. In this case, some functions of vim are very hard
" to reach.

" This file helps me in both cases.
" I made an alphabetical menu for some of the functions for the normal mode.
" 
" Drop this file in your plugin dir
" The next start of vim will show some new menus.
"
" There are some special sub-menus
" i = shift
" k = control
" l = alt
" If you want to reach all commands in Normal mode with Uppercase characters
" alt      invoke menu
"   n      normal-Mode commands
"     i    shift-commands
" Look at the bottom of the screen. Every command has a little tip. I took most
" tips from index.txt.

" tested with gvim 6.2, windows XP
" Knoppix 3.7: the tips are missing,  Hotkey only in left textarea possible


" ************************ FUNCTIONS *****************************
" Define Menu and Tip in one line
function! Menux(mapp,tree,tip,char) 
  " quote Blanks
  let tree = substitute (a:tree, ' ', '\\ ','g')
  " make menu-item
  execute a:char.'menu '.tree.' '.a:mapp
  " make tip for last item
  execute 'tmenu '.tree.' '.a:tip
endfunction

function Menui(mapp,tree,tip)
    call Menux(a:mapp,a:tree,a:tip,"i")
endfunction

function! Menua(mapp,tree,tip) 
    call Menux(a:mapp,a:tree,a:tip,"a")
endfunction

" *********************** Menu *************************************

"Normal Shift
call Menua('A'  , '&n.sh&ift.&Append end<tab>A'        , 'Append text after the end of the line N times')
call Menua('B'  , '&n.sh&ift.&Back word<tab>B'         , 'Cursor N WORDS backward')
call Menua('C'  , '&n.sh&ift.&Change rest<tab>C'       , 'Change rest of line, start insert mode')
call Menua('D'  , '&n.sh&ift.&Delete rest<tab>D'       , 'Delete rest of line')
call Menua('E'  , '&n.sh&ift.&End of word<tab>E'       , 'Cursor forward to the end of WORD N')
call Menua('F'  , '&n.sh&ift.&Find char back<tab>F'    , 'find next char backwards in line')
call Menua('G'  , '&n.sh&ift.&Go end of file<tab>G'    , 'Cursor to line N, default last line (end of text)')
call Menua('H'  , '&n.sh&ift.&Hop to top<tab>H'        , 'Cursor to line N from top of screen')
call Menua('I'  , '&n.sh&ift.&Insert first<tab>I'      , 'Insert text before the first CHAR on the line N times')
call Menua('J'  , '&n.sh&ift.&Join lines<tab>J'        , 'Join N lines')
call Menua('K'  , '&n.sh&ift.&Keyword help<tab>K'      , 'Lookup Keyword under the cursor with keywordprg')
call Menua('L'  , '&n.sh&ift.&Last line<tab>L'         , 'Cursor to line N from bottom of screen')
call Menua('M'  , '&n.sh&ift.&Middle line<tab>M'       , 'Cursor to middle line of screen')
call Menua('N'  , '&n.sh&ift.&Next search back<tab>N'  , 'Repeat the latest / or ? N times in opposite direction')
call Menua('O'  , '&n.sh&ift.&Open above <tab>O'       , 'Begin (N) new line above the cursor and insert text ')
call Menua('P'  , '&n.sh&ift.&Put text <tab>P'         , 'Put text before Cursor')
call Menua('Q'  , '&n.sh&ift.&Quit to Ex<tab>Q'        , 'Switch to Ex mode')
call Menua('R'  , '&n.sh&ift.&Replace<tab>R'           , 'Enter replace mode: overtype existing characters. Repeat the entered text N-1 times')
call Menua('S'  , '&n.sh&ift.&Subst line<tab>S'        , 'Substitute whole line an start insert text at Pos 0')
call Menua('T'  , '&n.sh&ift.&To char back<tab>T'      , 'jump to char back in line')
call Menua('U'  , '&n.sh&ift.&Undo line<tab>U'         , 'Undo all latest changes on one line')
call Menua('V'  , '&n.sh&ift.&Visual linewise<tab>V'   , 'Start linewise Visual mode')
call Menua('W'  , '&n.sh&ift.Next &word<tab>W'         , 'Cursor to next word separated by space')
call Menua('X'  , '&n.sh&ift.&X Backspace<tab>X'       , 'Backspace')
call Menua('Y'  , '&n.sh&ift.&Yank line<tab>Y'         , 'remember line in registert (yank)')
call Menua('Z'  , '&n.sh&ift.Quit &z<tab>Z'            , 'Save and Quit')

"Normal Control
call Menua('<C-a>'  , '&n.&k-control.&Add<tab>^a'               , 'add N to number at/after cursor')
call Menua('<C-b>'  , '&n.&k-control.Screens &back<tab>^b'      , 'scroll N screens backwards ')
call Menua('<C-c>'  , '&n.&k-control.Interrupt (&c)<tab>^c'     , 'interrupt current (search) command')
call Menua('<C-d>'  , '&n.&k-control.Scroll &down<tab>^d'       , 'scroll down n lines or half a screen')
call Menua('<C-e>'  , '&n.&k-control.Scroll Up(&e)<tab>^e'      , 'scroll n lines upwards')
call Menua('<C-f>'  , '&n.&k-control.Screen &forward<tab>^f'    , 'scroll n screens forwards')
call Menua('<C-g>'  , '&n.&k-control.Filename(&g)<tab>^g'       , 'display current file name and position')
call Menua('<C-l>'  , '&n.&k-control.Redraw screen(&l)<tab>^l'  , 'redraw screen')
call Menua('<C-o>'  , '&n.&k-control.&Older jump<tab>^o'        , 'go to N older entry in jump list')
call Menua('<C-p>'  , '&n.&k-control.Go U&p<tab>^p'             , 'cursor n lines upwards')
call Menua('<C-r>'  , '&n.&k-control.&Redo changes<tab>^r'      , 'redo changes which were undone with u')
call Menua('<C-t>'  , '&n.&k-control.Jump older &tag<tab>^t'    , 'jump to an older tag in tag list')
call Menua('<C-u>'  , '&n.&k-control.Scroll &up<tab>^u'         , 'scroll n lines upwards')
call Menua('<C-v>'  , '&n.&k-control.&Visual block<tab>^v'      , 'start blockwise visual mode')
call Menua('<C-x>'  , '&n.&k-control.Subtract(&x)<tab>^x'       , 'subtract N from number at/after cursor')
call Menua('<C-y>'  , '&n.&k-control.Scroll down(&y)<tab>^y'    , 'scroll n lines downwards')
call Menua('<C-z>'  , '&n.&k-control.Suspend(&z)<tab>^z'        , 'suspend program (or start a new shell)')

"Normal Bracket open [
call Menua('[#'  , '&n.&[.Prev &#if<tab>[&#'             , 'Cursor to N previous unmatched #if, #else or #ifdef')
call Menua('[('  , '&n.&[.Back unmatched &(<tab>[&('     , 'Cursor N times back to unmatched Paranthese')
call Menua('[*'  , '&n.&[.To prev Comment(&*)<tab>[&*'   , 'Cursor to N previous start of a C Comment')
call Menua('[`'  , '&n.&[.To prev Mark(&`)<tab>[&`'      , 'Cursor to prev lowercase mark')
call Menua('[/'  , '&n.&[.To prev Comment(&/)<tab>[&/'   , 'Cursor to N previous start of a C Comment')
call Menua('[D'  , '&n.&[.List &defines<tab>[&D'         , 'List all defines found in current and includet files that contain the word under the cursor')
call Menua('[I'  , '&n.&[.L&ist lines<tab>[&I'           , 'List all lines in current and includet files that contain the word under the cursor')
call Menua('[['  , '&n.&[.Section Back(&[)<tab>[&['      , 'Cursor N sections backward')
call Menua('[c'  , '&n.&[.To start of &change<tab>[&c'   , 'Cursor N times backwards to start of change')
call Menua('[d'  , '&n.&[.First #&define<tab>[&d'        , 'Show first #define found in current and included files matching the word under the cursor')
call Menua('[f'  , '&n.&[.Go &file<tab>[&f'              , 'Go to file under the Cursor')
call Menua('[i'  , '&n.&[.L&ines cursorword<tab>[&i'     , 'Show first line found in current and included files that contain the word under the cursor')
call Menua('[m'  , '&n.&[.To &Memberfunction<tab>[&m'    , 'Cursor N times back to start of member function')
call Menua('[z'  , '&n.&[.To start of fold(&z)<tab>[&z'  , 'Move to start of open fold')
call Menua('[{'  , '&n.&[.Back unmatched &{<tab>[{'      , 'Cursor N times back to unmatched {')

"Normal Bracket Close ]
call Menua(']#'          , '&n.-&].Next &#if<tab>]#'               , 'Cursor to N next unmatched #endif or #else')
call Menua('])'          , '&n.-&].To unmatched &)<tab>])'         , 'Cursor N times forward to unmatched )')
call Menua(']*'          , '&n.-&].To prev comment(&*)<tab>]*'     , 'Cursor to N previous start of a C comment')
call Menua(']`'          , '&n.-&].To next mark(&`)<tab>]`'        , 'Cursor to next lowercase mark')
call Menua(']/'          , '&n.-&].To prev comment(&/)<tab>]/'     , 'Cursor to N previous start of a C comment')
call Menua(']D'          , '&n.-&].List &defines<tab>]D'           , 'List all defines found in current and included files that contain the word under the cursor')
call Menua(']I'          , '&n.-&].L&ist lines<tab>]I'             , 'List all lines found in current and included files that contain the word under the cursor')
call Menua(']c'          , '&n.-&].To start of &change<tab>]c'     , 'Cursor N times forward to start of change')
call Menua(']d'          , '&n.-&].First #&define<tab>]d'          , 'Show first #define found in current and included files that contain the word under the cursor')
call Menua(']f'          , '&n.-&].Go &file<tab>]f'                , 'Go to file under the cursor')
call Menua(']i'          , '&n.-&].L&ines cursorword<tab>]i'       , 'Show first line found in current included files that contain the word under the cursor')
call Menua(']m'          , '&n.-&].To &Memberfunction end<tab>]m'  , 'Cursor N times forward to end of member function')
call Menua(']z'          , '&n.-&].To end of fold(&z) <tab>]z'     , 'Move to end of open fold')
call Menua(']}'          , '&n.-&].Forward unmatched &}<tab>]}'    , 'Cursor N times forward to unmatched }')

"normal Mode
call Menua('a'  , '&n.&Append<Tab>a'       , 'Start inserting Text after the cursor')
call Menua('b'  , '&n.&Back word<tab>b'    , 'jump back one Word')
call Menua('c'  , '&n.&Change<tab>c'       , 'change motion. Delete motion and start insert')
call Menua('d'  , '&n.&Delete<tab>d'       , 'Delete motion.')
call Menua('e'  , '&n.&End of word<tab>e'  , 'Jump to end of (next) word.')
call Menua('f'  , '&n.&Find char<tab>f'    , 'Jump to next char in line. Repeat with ;')
call Menua('m'  , '&n.&Mark char<tab>m'    , 'remember position in register "char".')
call Menua('n'  , '&n.&Next search<tab>n'  , 'Find next search position')
call Menua('o'  , '&n.&Open line<tab>o'    , 'Insert new line under current line and start inserting')
call Menua('p'  , '&n.&Put<tab>p'          , 'Insert content of register after Cursor')
call Menua('q'  , '&n.Record &q<tab>q'  , 'Record typed characters into register (uppercase to append). Stop with q again. Play with @ char')
call Menua('r'  , '&n.&Replace<tab>r'      , 'Replace one (N) chars with next typed char. R replaces permanently')
call Menua('s'  , '&n.&Substitute<tab>s'   , 'Delete one (N) char. Start inserting.  S replaces whole line.')
call Menua('t'  , '&n.&To char<tab>t'      , 'jump in front of "char" in line. ; repeats thist jump')
call Menua('u'  , '&n.&Undo<tab>u'         , 'Undo last change')
call Menua('v'  , '&n.&Visual mode<tab>v'  , 'Visual mode. Highlight all following motion. V visual line mode. ^v visual block mode')
call Menua('w'  , '&n.&Word jump<tab>w'    , 'Jump to start of next word.')
call Menua('x'  , '&n.&x Delete<tab>x'       , 'Delete one (N) char.')
call Menua('y'  , '&n.&Yank<tab>y'         , 'Yank motion into register.')

"Normal Other
call Menua('#'   , '&n.Searchback CWord(&#)<tab>#'  , 'Search backward for the Nth occurence of the ident under the cursor')
call Menua('$'   , '&n.End of line(&$)<tab>$'       , 'Cursor to the end of Nth next Line')
call Menua('%'   , '&n.Find bracket(&%)<tab>%'      , 'Find the next (curly/square) bracket on this line and go to')
call Menua('&'   , '&n.Substitute again<tab>&&'     , 'Repeat last :s')
call Menua('*'   , '&n.Search CWord(&*)<tab>*'      , 'Search forward for the Nth occurence of the ident unter the cursor')
call Menua('+'   , '&n.Down (&+)<tab>+'             , 'Cursor to the first CHAR N Lines down')
call Menua('-'   , '&n.Up (&-)<tab>-'               , 'Cursor to the first CHAR N Lines higher')
call Menua(','   , '&n.Repeat back char(&,)<tab>,'  , 'Repeat latest f, t, F or T in opposite direction N times')
call Menua(';'   , '&n.Repeat find char(&;)<tab>;'  , 'Repeat latest f, t, F or T N times')
call Menua('.'   , '&n.Repeat change(&\.)<tab>\.'   , 'Repeat last change with a count replaced with N')
call Menua('<<'  , '&n.Shift left(&\<)<tab><<'      , 'Shift N lines one shiftwidth leftwards')
call Menua('>>'  , '&n.Shift right(&\>)<tab>>>'     , 'Shift N lines one shiftwidth rightwards')
call Menua('@:'  , '&n.Repeat Command(&@)<tab>@:'   , 'Repeat the previous ":" command N times')

"G Shift
call Menua('gD'       , '&g.sh&ift.&Definition<tab>gD'        , 'go to definition of word under the cursor in current file')
call Menua('gE'       , '&g.sh&ift.&End word back<tab>gE'     , 'Go backwards to the end of the previous WORD')
call Menua('gH'       , '&g.sh&ift.&Highlight Line<tab>gH'    , 'start Select line mode')
call Menua('gI'       , '&g.sh&ift.&Insert<tab>gI'            , 'like I. Always start in column 1')
call Menua('gJ'       , '&g.sh&ift.&Join<tab>gJ'              , 'join lines without inserting space')
call Menua('gR'       , '&g.sh&ift.&Replace<tab>gR'           , 'enter Virtual Replace mode')
"G Control
call Menua('g_<C-G>'  , '&g.&k-control.&Get info<tab>g^g'     , 'Show information about current cursor position')
call Menua('g_<C-]>'  , '&g.&k-control.Tag jump(&])<tab>g^]'  , ':tjump to the tag under the cursor')

"G
call Menua('g#'  , '&g.match back(&#)<tab>g#'     , 'search CWord backward. Not only whole words')
call Menua('g$'  , '&g.End (&$)<tab>g$'           , 'When wrap off go to rightmost character of the current line that is on the screen')
call Menua('g&'  , '&g.Repeat<tab>g&&'            , 'Repeat last substitute on all lines')
call Menua('g*'  , '&g.match (&*)<tab>g*'         , 'search CWord forward. Not only whole words')
call Menua('g0'  , '&g.Left (&0)<tab>g0'          , 'to leftmost character of the current line that is on the screen')
call Menua('g8'  , '&g.Hex (&8)<tab>g8'           , 'print hex value of bytes used in UTF-8 character under the cursor')
call Menua('g?'  , '&g.Rot13 (&?)<tab>g?'         , 'Rot13 encoding operator')
call Menua('g]'  , '&g.Select Tag <tab>g]'        , ':tselect on the tag under the cursor')
call Menua('g^'  , '&g.Left black<tab>g^'         , 'when wrap off go to leftmost non-white character of the current line that is on')
call Menua('ga'  , '&g.&Ascii<tab>ga'             , 'print ascii value of character under the cursor')
call Menua('gd'  , '&g.&Definition local<tab>gd'  , 'go to local definition of word under the cursor in current function')
call Menua('ge'  , '&g.End Word<tab>ge'           , 'go backwards to the end of the previous word')
call Menua('gf'  , '&g.&File edit<tab>gf'         , 'start editing the file whose name is under the cursor')
call Menua('gg'  , '&g.&Go Line<tab>gg'           , 'cursor to line N. Default first line')
call Menua('gh'  , '&g.Select (&h)<tab>gh'        , 'Start Select mode')
call Menua('gi'  , '&g.&Insert at mark<tab>gi'    , 'move to mark and start insert')
call Menua('gj'  , '&g.Down(&j)<tab>gj'           , 'like j. But when wrap on go N screen lines down')
call Menua('gk'  , '&g.Up<tab>gk'                 , 'like k. But when wrap on go N screen lines up')
call Menua('gm'  , '&g.To &middle char<tab>gm'    , 'go to character at middle of the screenline')
call Menua('go'  , '&g.T&o Byte<tab>go'           , 'cursor to byte N in the buffer')
call Menua('gp'  , '&g.&Put<tab>gp'               , 'put the text after the cursor N times. Leave the cursor after it')
call Menua('gq'  , '&g.Format (&q)<tab>gq'        , 'format next move text')
call Menua('gr'  , '&g.&Replace<tab>gr'           , 'virtual replace N chars with {char}')
call Menua('gs'  , '&g.&Sleep<tab>gs'             , 'go to sleep for N seconds (default 1)')
call Menua('gu'  , '&g.Lowercase <tab>g&u'        , 'make next move text lowercase')
call Menua('gv'  , '&g.Prev &visual<tab>g&v'      , 'reselect the previous Visual area')
call Menua('g~'  , '&g.Swap case (&~)<tab>g~'     , 'swap case for motion.  g~~ for switch case of current line')

"z-Shift
call Menua('zA'  , '&z.sh&ift.Open &a fold<tab>zA'      , 'open a closed fold or close an open fold recursively')
call Menua('zC'  , '&z.sh&ift.&Close all folds<tab>zC'  , 'close folds recursively')
call Menua('zD'  , '&z.sh&ift.&Delete folds<tab>zD'     , 'delete folds recursively')
call Menua('zE'  , '&z.sh&ift.&Eliminate<tab>zE'        , 'eliminate all folds')
call Menua('zF'  , '&z.sh&ift.&Fold<tab>zF'             , 'create a fold for N lines')
call Menua('zM'  , '&z.sh&ift.Foldlevel 0 (&M)<tab>zM'  , 'set foldlevel to zero')
call Menua('zN'  , '&z.sh&ift.Fold &normal <tab>zN'     , 'All folds will be as they were before zn(=fold none)')
call Menua('zO'  , '&z.sh&ift.&Open all folds<tab>zO'   , 'open folds recursively')
call Menua('zR'  , '&z.sh&ift.Fold &real deep<tab>zR'   , 'set foldlevel to the deepest fold')
call Menua('zX'  , '&z.sh&ift.Reapply (&X)<tab>zX'      , 're-apply foldlevel')

"z
call Menua('z<CR>'  , '&z.To top<tab>z<CR>'           , 'cursor line to top of window. cursor on first non-blank')
call Menua('z+'     , '&z.Below Window (&+)<tab>z+'   , 'cursor on line N (default line below window). otherwise like "z<CR>"')
call Menua('z-'     , '&z.Bottom (&-)<tab>z-'         , 'cursor line at bottom of window. cursor on first non-blank')
call Menua('z.'     , '&z.Line center (&\.)<tab>z\.'  , 'cursor line to center of window. cursor on first non-blank')
call Menua('z^'     , '&z.To above (&^)<tab>z^'       , 'cursor on line N (default line above window). otherwise like "z-"')
call Menua('za'     , '&z.Toggle &a Fold<tab>za'      , 'open a closed fold. close an open fold')
call Menua('zb'     , '&z.Line &bottom<tab>zb'        , 'cursor line at bottom of window')
call Menua('zc'     , '&z.Fold &close<tab>zc'         , 'Close a fold')
call Menua('zd'     , '&z.Fold &delete<tab>zd'        , 'Delete a fold')
call Menua('ze'     , '&z.Scroll &end<tab>ze'         , 'when wrap off scroll horizontally to position the cursor at the end (right side) of the screen. See: zs')
call Menua('zf'     , '&z.&Fold<tab>zf'               , 'create a fold for Nmove text')
call Menua('zh'     , '&z.Scroll rig&ht<tab>zh'       , 'when wrap off scroll screen N characters to the right ')
call Menua('zi'     , '&z.Fold toggle <tab>zi'        , 'toggle foldenable')
call Menua('zj'     , '&z.To next fold (&j)<tab>zj'   , 'move to the start of the next fold')
call Menua('zk'     , '&z.To prev fold <tab>zk'       , 'move to the end of the previous fold')
call Menua('zl'     , '&z.Scroll &left<tab>zl'        , 'when wrap off scroll screen N characters to the left')
call Menua('zm'     , '&z.Fold &more<tab>zm'          , 'subtract one from foldlevel')
call Menua('zn'     , '&z.Fold &none<tab>zn'          , 'reset foldenable. All folds will  ')
call Menua('zo'     , '&z.Fold &open<tab>zo'          , 'Open fold')
call Menua('zr'     , '&z.Fold &reduce<tab>zr'        , 'Add one to foldlevel. Reduce folding')
call Menua('zs'     , '&z.&Scroll to Cursor<tab>zs'   , 'when wrap off scroll horizontally to position the cursor at the start (left side) of the screen. See: ze')
call Menua('zt'     , '&z.Line &top<tab>zt'           , 'cursor line at top of window')
call Menua('zv'     , '&z.Fold &view<tab>zv'          , 'open enough folds to view the cursor line')
call Menua('zx'     , '&z.Fold update(&x)<tab>zx'     , 're-apply foldlevel and do "view fold"')
call Menua('zz'     , '&z.Line Center (&z) <tab>zz'   , 'cursor line at center of window')


