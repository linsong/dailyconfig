" File:         TagsParser.Vim
" Description:  Dynamic file tagging and mini-window to display tags
" Version:      0.4
" Date:         June 11, 2006
" Author:       A. Aaron Cornelius (ADotAaronDotCorneliusAtgmailDotcom)
"
" Installation:
" ungzip and untar The TagsParser.tar.gz somewhere in your Vim runtimepath
" (typically this should be something like $HOME/.Vim, $HOME/vimfiles or
" $VIM/vimfiles) Once this is done run :helptags <dir>/doc where <dir> is The
" directory that you ungziped and untarred The TagsParser.tar.gz archive in.
"
" Usage:
" For help on The usage of this plugin to :help TagsParser after you have
" finished The installation steps.
"
" Changelog:
" 0.4 - First bugfix release - 06/11/2006
"
" 06/09/2006 - Added some GCOV extensions (*.da, *.bb, *.bbg, *.gcov) to file
"              exclude pattern.
" 06/09/2006 - Added GNAT build artifact extension (*.ali) to file exclude
"              pattern.
" 06/09/2006 - Fixed some spelling errors in messages and comments.
" 06/09/2006 - Added standard library extensions (*.a, *.so) to file exclude
"              pattern.
" 06/09/2006 - Changed include/exclude regular expressions into Vim regexps 
"              instead of Perl regexps.
" 06/08/2006 - Fixed issues with spaces in paths (mostly of... The root of it
"              is when Ctags is using The external sort... at least on Win32).
" 06/08/2006 - Fixed issue where tag files are created for directory names 
"              when using The TagDir command.
" 06/02/2006 - Added Copyright notice. 
" 06/02/2006 - Fixed tag naming issue where if you have 
"              TagsParserCtagsOptions* options defined, it messes up The name
"              of The tag file.
" 05/26/2006 - Added nospell to local TagWindow options for Vim 7.
"
" 0.3 - Initial Public Release - 05/07/2006
"
" Future Changes:
" TODO: Move as much external code (Perl) to internal vimscript.
"       - use Vim dictionary instead of Perl hash
" TODO: Make compatible with Tab pages for Vim 7.
" TODO: allow The definition of separate tag paths depending on The current 
"       working directory
" TODO: read in a file when doing TagDir so that The correct options are used 
"       to tag The file
"
" Bug List:
"
"
" Copyright (C) 2006 A. Aaron Cornelius
"
" This program is free software; you can redistribute it and/or
" modify it under The terms of The GNU General Public License
" as published by The Free Software Foundation; either version 2
" of The License, or (at your option) any later version.
"
" This program is distributed in The hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even The implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See The
" GNU General Public License for more details.
"
" You should have received a copy of The GNU General Public License
" along with this program; if not, write to The Free Software
" Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
" USA.

let s:cpoSave = &cpo
set cpo&vim

" Init Check <<<
if exists('s:TagsParserLoaded')
  finish
endif
let s:TagsParserLoaded = 1
" >>>

" Configuration

" Perl Check <<<
if !has('Perl')
  if !exists('g:TagsParserNoPerlWarning') || g:TagsParserNoPerlWarning == 0
    echomsg "You must have a perl enabled version of VIM to use full functionality of TagsParser plugin."
    echomsg "(to disable this warning set The g:TagsParserNoPerlWarning variable to 1 in your .vimrc)"
  endif
  finish
endif
" >>>
" Global Variables <<<
if !exists("g:TagsParserCtagsOptions")
  let g:TagsParserCtagsOptions = ""
endif

if !exists("g:TagsParserOff")
  let g:TagsParserOff = 0
endif

if !exists("g:TagsParserLastPositionJump")
  let g:TagsParserLastPositionJump = 0
endif

if !exists("g:TagsParserNoNestedTags")
  let g:TagsParserNoNestedTags = 0
endif

if !exists("g:TagsParserNoTagWindow")
  let g:TagsParserNoTagWindow = 0
endif

if !exists("g:TagsParserWindowLeft")
  let g:TagsParserWindowLeft = 0
endif

if !exists("g:TagsParserHorizontalSplit")
  let g:TagsParserHorizontalSplit = 0
endif

if !exists("g:TagsParserWindowTop")
  let g:TagsParserWindowTop = 0
endif

"based on The window position configuration variables, setup the tags window 
"split command
if g:TagsParserWindowLeft != 1 && g:TagsParserHorizontalSplit != 1
  let s:TagsWindowPosition = "botright vertical"
elseif g:TagsParserHorizontalSplit != 1
  let s:TagsWindowPosition = "topleft vertical"
elseif g:TagsParserWindowTop != 1
  let s:TagsWindowPosition = "botright"
else
  let s:TagsWindowPosition = "topleft"
endif

if !exists("g:TagsParserFoldColumnDisabled")
  let g:TagsParserFoldColumnDisabled = 0
endif

if !exists("g:TagsParserWindowSize")
  let g:TagsParserWindowSize = 40
endif

if !exists("g:TagsParserWindowName")
  let g:TagsParserWindowName = "__tags__"
endif

if !exists('g:TagsParserSingleClick')
  let g:TagsParserSingleClick = 0
endif

if !exists("g:TagsParserHighlightCurrentTag")
  let g:TagsParserHighlightCurrentTag = 0
endif

if !exists("g:TagsParserAutoOpenClose")
  let g:TagsParserAutoOpenClose = 0
endif

if !exists("g:TagsParserBufExplWorkAround")
  let g:TagsParserBufExplWorkAround = 0
endif

if !exists("g:TagsParserNoResize")
  let g:TagsParserNoResize = 0
endif

if !exists("g:TagsParserSortType") || g:TagsParserSortType != "line"
  let g:TagsParserSortType = "alpha"
endif

if !exists("g:TagsParserDisplaySignature")
  let g:TagsParserDisplaySignature = 0
endif

"if we are in the C:/WINDOWS/SYSTEM32 dir, change to C.  Odd things seem to
"happen if we are in the system32 directory
if has('win32') && getcwd() ==? 'C:\WINDOWS\SYSTEM32'
  let s:cwdChanged = 1
  cd C:\
else
  let s:cwdChanged = 0
endif

"if the tags program has not been specified by a user level global define,
"find the right tags program.  This checks exuberant-ctags first to handle the
"case where multiple tags programs are installed it is differentiated by an
"explicit name
if !exists("g:TagsParserTagsProgram")
  if executable("exuberant-ctags")
    let g:TagsParserTagsProgram = "exuberant-ctags"
  elseif executable("ctags")
    let g:TagsParserTagsProgram = "ctags"
  elseif executable("ctags.exe")
    let g:TagsParserTagsProgram = "ctags.exe"
  elseif executable("tags")
    let g:TagsParserTagsProgram = "tags"
  else
    echomsg "TagsParser - tags program not found, go to " .
          \"http://ctags.sourceforge.net/ to download it.  OR"
          \"specify the path to a the Exuberant Ctags program " .
          \"using the g:TagsParserTagsProgram variable in your .vimrc"
    finish
  endif
endif

if system(g:TagsParserTagsProgram . " --version") !~? "Exuberant Ctags"
  echomsg "TagsParser - ctags = " . g:TagsParserTagsProgram . " go to"
        \"http://ctags.sourceforge.net/ to download it.  OR"
        \"specify the path to a the Exuberant Ctags program " .
        \"using the g:TagsParserTagsProgram variable in your .vimrc"
  finish
endif

if s:cwdChanged == 1
  cd C:\WINDOWS\SYSTEM32
endif

"These variables are in Vim-style regular expressions, not per-style like they 
"used to be.  See ":help usr_27.txt" and ":help regexp" for more information.
"If the patterns are empty then they are considered disabled

"Init the directory exclude pattern to remove any . or _ prefixed directories
"because they are generally considered 'hidden'.  This will also have the
"benefit of preventing the tagging of any .tags directories
if !exists("g:TagsParserDirExcludePattern")
  let g:TagsParserDirExcludePattern = '.\+/\..\+\|.\+/_.\+\|\%(\ctmp\)\|' .
        \ '\%(\ctemp\)\|\%(\cbackup\)'
endif

if !exists("g:TagsParserDirIncludePattern")
  let g:TagsParserDirIncludePattern = ""
endif

"Init the file exclude pattern to take care of typical object, library
"backup, swap, dependency and tag file names and extensions, build artifacts, 
"gcov extenstions, etc.
if !exists("g:TagsParserFileExcludePattern")
  let g:TagsParserFileExcludePattern = '^.*\.\%(\co\)$\|^.*\.\%(\cobj\)$\|' .
        \ '^.*\.\%(\ca\)$\|^.*\.\%(\cso\)$\|^.*\.\%(\cd\)$\|' .
        \ '^.*\.\%(\cbak\)$\|^.*\.\%(\cswp\)$\|^.\+\~$\|' .
        \ '^\%(\ccore\)$\|^\%(\ctags\)$\|^.*\.\%(\ctags\)$\|' .
        \ '^.*\.\%(\ctxt\)$\|^.*\.\%(\cali\)$\|^.*\.\%(\cda\)$\|' .
        \ '^.*\.\%(\cbb\)$\|^.*\.\%(\cbbg\)$\|^.*\.\%(\cgcov\)$'
endif

if !exists("g:TagsParserFileIncludePattern")
  let g:TagsParserFileIncludePattern = ""
endif

" >>>
" Script Autocommands <<<
" No matter what, always install The LastPositionJump autocommand, if enabled
if g:TagsParserLastPositionJump == 1
  au BufWinEnter * if line("'\"") > 0 && line("'\"") <= line("$") | exec "normal g`\"" | endif
endif
" only install the autocommands if the g:TagsParserOff variable is not set
if g:TagsParserOff == 0 && g:TagsParserNoTagWindow == 0
  augroup TagsParserAutoCommands
    autocmd!
    "setup an autocommand that will expand the path described by
    "g:TagsParserTagsPath into a valid tag path
    autocmd VimEnter * call <SID>TagsParserExpandTagsPath() |
          \ call <SID>TagsParserPerformOp("open", "")

    "setup an autocommand so that when a file is written to it writes a tag
    "file if it a file that is somewhere within the tags path or the
    "g:TagsParserTagsPath path
    autocmd BufWritePost ?* call <SID>TagsParserPerformOp("tag", "")
  augroup end

  augroup TagsParserBufWinEnterWindowNotOpen
    autocmd BufWinEnter ?* call <SID>TagsParserPerformOp("open", "")
  augroup end
elseif g:TagsParserOff == 0 && g:TagsParserNoTagWindow == 1
  augroup TagsParserAutoCommands
    autocmd!
    "setup an autocommand that will expand the path described by
    "g:TagsParserTagsPath into a valid tag path
    autocmd VimEnter * call <SID>TagsParserExpandTagsPath()

    "setup an autocommand so that when a file is written to it writes a tag
    "file if it a file that is somewhere within the tags path or the
    "g:TagsParserTagsPath path
    autocmd BufWritePost ?* call <SID>TagsParserPerformOp("tag", "")
  augroup end
endif
" >>>
" Setup Commands <<<

" TagsParser functionality
command! -nargs=0 TagsParserToggle :call <SID>TagsParserToggle()
nmap <leader>t<space> :TagsParserToggle<CR>

command! -nargs=+ -complete=dir TagDir 
      \ :call <SID>TagsParserSetupDirectoryTags(<q-args>)

" Turning TagsParser functionality completely off (and then back on)
command! -nargs=0 TagsParserOff :call <SID>TagsParserOff()
nmap <leader>tof :TagsParserOff<CR>
command! -nargs=0 TagsParserOn :call <SID>TagsParserOn()
nmap <leader>ton :TagsParserOn<CR>

" do a copen/cwindow so The quickfix window stretches over the whole window
command! -nargs=* TagsParserCBot :botright copen <args>
nmap <leader>tbo :TagsParserCBot<CR>
command! -nargs=* TagsParserCBotWin :botright cwindow <args>
nmap <leader>tbw :TagsParserCBotWin<CR>

" do a 'smart' copen/cwindow so that the quickfix window is only below the
" main window
command! -nargs=* TagsParserCOpen :call <SID>TagsParserCOpen(<f-args>)
nmap <leader>to :TagsParserCOpen<CR>
command! -nargs=* TagsParserCWindow :call <SID>TagsParserCWindow(<f-args>)
nmap <leader>tw :TagsParserCWindow<CR>

" for convenience
nmap <leader>tc :cclose
" >>>
" Initialization <<<

" Check for any depreciated variables and options
if exists("g:MyTagsPath")
  echomsg "The MyTagsPath variable is depreciated, please use TagsParserTagsPath instead.\nThis path should be set in The same way that all VIM paths are, using commas instead of spaces.  Please see ':help path' for more information."
endif

if exists("g:TagsParserFindProgram")
  echomsg "The TagsParserFindProgram variable is no longer necessary, you can remove it from your .vimrc"
endif

"if we are in the C:/WINDOWS/SYSTEM32 dir, change to C.  Odd things seem to
"happen if we are in the system32 directory
if has('win32') && getcwd() ==? 'C:\WINDOWS\SYSTEM32'
  let s:cwdChanged = 1
  cd C:\
else
  let s:cwdChanged = 0
endif

if s:cwdChanged == 1
  cd C:\WINDOWS\SYSTEM32
endif

"init the matched tag fold flag
let s:matchedTagFoldStart = 0
let s:matchedTagFoldEnd = 0
let s:matchedTagWasFolded = 0

"init the update values 
let s:tagsDataUpdated = 1
let s:lastFileDisplayed = ""

let s:newBufBeingCreated = 0

"setup the mappings to handle single click
if g:TagsParserSingleClick == 1
  let s:clickmap = ':if bufname("%") == g:TagsParserWindowName <bar> call <SID>TagsParserSelectTag() <bar> endif <CR>'
  if maparg('<LeftMouse>', 'n') == '' 
    " no mapping for leftmouse
    exec ':nnoremap <silent> <LeftMouse> <LeftMouse>' . s:clickmap
  else
    " we have a mapping
    let  s:m = ':nnoremap <silent> <LeftMouse> <LeftMouse>'
    let  s:m = s:m . substitute(substitute(maparg('<LeftMouse>', 'n'), '|', '<bar>', 'g'), '\c^<LeftMouse>', '', '')
    let  s:m = s:m . s:clickmap
    exec s:m
  endif
endif

" TagsParserPerlInit - Init the default type names <<<
function! <SID>TagsParserPerlInit()
perl << PerlFunc
  use strict;
  use warnings;
  no warnings 'redefine';

  # define the data needed for displaying the tag data, define it in
  # the order desired for parsing, and each entry has the key into the
  # tags hash, the title for those types, and what fold level to put it at
  # the default fold level is 3 which allows for something along the lines of
  # namespace->class->function()

  # if you define a new set of types, make sure to prefix the name with
  # a "- " string so that it will be picked up by the "Type" syntax
  my @adaTypes = ( [ "P", "- Package Specs" ],
                   [ "p", "- Packages" ],
                   [ "T", "- Type Specs" ],
                   [ "t", "- Types" ],
                   [ "U", "- Subtype Specs" ],
                   [ "u", "- Subtypes" ],
                   [ "c", "- Components" ],
                   [ "l", "- Literals" ],
                   [ "V", "- Variable Specs" ],
                   [ "v", "- Variables" ],
                   [ "n", "- Constants" ],
                   [ "x", "- Exceptions" ],
                   [ "f", "- Formal Params" ],
                   [ "R", "- Subprogram Specs" ],
                   [ "r", "- Subprograms" ],
                   [ "K", "- Task Specs" ],
                   [ "k", "- Tasks" ],
                   [ "O", "- Protected Data Specs" ],
                   [ "o", "- Protected Data" ],
                   [ "E", "- Entry Specs" ],
                   [ "e", "- Entries" ],
                   [ "b", "- Labels" ],
                   [ "i", "- Identifiers" ],
                   [ "a", "- Auto Vars" ],
                   [ "y", "- Blocks" ] );

  my @asmTypes = ( [ "d", "- Defines" ],
                   [ "t", "- Types" ],
                   [ "m", "- Macros" ],
                   [ "l", "- Labels" ] );

  my @aspTypes = ( [ "f", "- Functions" ],
                   [ "s", "- Subroutines" ],
                   [ "v", "- Variables" ] );

  my @awkTypes = ( [ "f", "- Functions" ] );

  my @betaTypes = ( [ "f", "- Fragment Defs" ],
                    [ "p", "- All Patterns" ],
                    [ "s", "- Slots" ],
                    [ "v", "- Patterns" ] );

  my @cTypes = ( [ "n", "- Namespaces" ],
                 [ "c", "- Classes" ],
                 [ "d", "- Macros" ],
                 [ "t", "- Typedefs" ],
                 [ "s", "- Structures" ],
                 [ "g", "- Enumerations" ],
                 [ "u", "- Unions" ],
                 [ "x", "- External Vars" ],
                 [ "v", "- Variables" ],
                 [ "p", "- Prototypes" ],
                 [ "f", "- Functions" ],
                 [ "m", "- Struct/Union Members" ],
                 [ "e", "- Enumerators" ],
                 [ "l", "- Local Vars" ] );

  my @csTypes = ( [ "c", "- Classes" ],
                  [ "d", "- Macros" ],
                  [ "e", "- Enumerators" ],
                  [ "E", "- Events" ],
                  [ "f", "- Fields" ],
                  [ "g", "- Enumerations" ],
                  [ "i", "- Interfaces" ],
                  [ "l", "- Local Vars" ],
                  [ "m", "- Methods" ],
                  [ "n", "- Namespaces" ],
                  [ "p", "- Properties" ],
                  [ "s", "- Structs" ],
                  [ "t", "- Typedefs" ] );

  my @cobolTypes = ( [ "d", "- Data Items" ],
                     [ "f", "- File Descriptions" ],
                     [ "g", "- Group Items" ],
                     [ "p", "- Paragraphs" ],
                     [ "P", "- Program IDs" ],
                     [ "s", "- Sections" ] );

  my @eiffelTypes = ( [ "c", "- Classes" ],
                      [ "f", "- Features" ],
                      [ "l", "- Local Entities" ] );

  my @erlangTypes = ( [ "d", "- Macro Defs" ],
                      [ "f", "- Functions" ],
                      [ "m", "- Modules" ],
                      [ "r", "- Record Defs" ] );

  my @fortranTypes = ( [ "b", "- Block Data" ],
                       [ "c", "- Common Blocks" ],
                       [ "e", "- Entry Points" ],
                       [ "f", "- Functions" ],
                       [ "i", "- Interface Contents/Names/Ops" ],
                       [ "k", "- Type/Struct Components" ],
                       [ "l", "- Labels" ],
                       [ "L", "- Local/Common/Namelist Vars" ],
                       [ "m", "- Modules" ],
                       [ "n", "- Namelists" ],
                       [ "p", "- Programs" ],
                       [ "s", "- Subroutines" ],
                       [ "t", "- Derived Types/Structs" ],
                       [ "v", "- Program/Module Vars" ] );

  my @htmlTypes = ( [ "a", "- Named Anchors" ],
                    [ "f", "- Javascript Funcs" ] );

  my @javaTypes = ( [ "c", "- Classes" ],
                    [ "f", "- Fields" ],
                    [ "i", "- Interfaces" ],
                    [ "l", "- Local Vars" ],
                    [ "m", "- Methods" ],
                    [ "p", "- Packages" ] );

  my @javascriptTypes = ( [ "f", "- Functions" ] );

  my @lispTypes = ( [ "f", "- Functions" ] );

  my @luaTypes = ( [ "f", "- Functions" ] );

  my @makeTypes = ( [ "m", "- Macros" ] );

  my @pascalTypes = ( [ "f", "- Functions" ],
                      [ "p", "- Procedures" ] );

  my @perlTypes = ( [ "c", "- Constants" ],
                    [ "l", "- Labels" ],
                    [ "s", "- Subroutines" ] );

  my @phpTypes = ( [ "c", "- Classes" ],
                   [ "d", "- Constants" ],
                   [ "f", "- Functions" ],
                   [ "v", "- Variables" ] );

  my @pythonTypes = ( [ "c", "- Classes" ],
                      [ "m", "- Class Members" ],
                      [ "f", "- Functions" ] );

  my @rexxTypes = ( [ "s", "- Subroutines" ] );

  my @rubyTypes = ( [ "c", "- Classes" ],
                    [ "f", "- Methods" ],
                    [ "F", "- Singleton Methods" ],
                    [ "m", "- Mixins" ] );

  my @schemeTypes = ( [ "f", "- Functions" ],
                      [ "s", "- Sets" ] );

  my @shTypes = ( [ "f", "- Functions" ] );

  my @slangTypes = ( [ "f", "- Functions" ],
                     [ "n", "- Namespaces" ] );

  my @smlTypes = ( [ "e", "- Exception Defs" ],
                   [ "f", "- Function Defs" ],
                   [ "c", "- Functor Defs" ],
                   [ "s", "- Signatures" ],
                   [ "r", "- Structures" ],
                   [ "t", "- Type Defs" ],
                   [ "v", "- Value Bindings" ] );

  my @sqlTypes = ( [ "c", "- Cursors" ],
                   [ "d", "- Prototypes" ],
                   [ "f", "- Functions" ],
                   [ "F", "- Record Fields" ],
                   [ "l", "- Local Vars" ],
                   [ "L", "- Block Label" ],
                   [ "P", "- Packages" ],
                   [ "p", "- Procedures" ],
                   [ "r", "- Records" ],
                   [ "s", "- Subtypes" ],
                   [ "t", "- Tables" ],
                   [ "T", "- Triggers" ],
                   [ "v", "- Variables" ] );

  my @tclTypes = ( [ "c", "- Classes" ],
                   [ "m", "- Methods" ],
                   [ "p", "- Procedures" ] );

  my @veraTypes = ( [ "c", "- Classes" ],
                    [ "d", "- Macro Defs" ],
                    [ "e", "- Enumerators" ],
                    [ "f", "- Functions" ],
                    [ "g", "- Enumerations" ],
                    [ "l", "- Local Vars" ],
                    [ "m", "- Class/Struct/Union Members" ],
                    [ "p", "- Programs" ],
                    [ "P", "- Prototypes" ],
                    [ "t", "- Tasks" ],
                    [ "T", "- Typedefs" ],
                    [ "v", "- Variables" ],
                    [ "x", "- External Vars" ] );

  my @verilogTypes = ( [ "c", "- Constants" ],
                       [ "e", "- Events" ],
                       [ "f", "- Functions" ],
                       [ "m", "- Modules" ],
                       [ "n", "- Net Data Types" ],
                       [ "p", "- Ports" ],
                       [ "r", "- Register Data Types" ],
                       [ "t", "- Tasks" ] );

  my @vimTypes = ( [ "a", "- Autocommand Groups" ],
                   [ "f", "- Functions" ],
                   [ "v", "- Variables" ] );

  my @yaccTypes = ( [ "l", "- Labels" ] );

  our %typeMap : unique = ( ada => \@adaTypes,
                            asm => \@asmTypes,
                            asp => \@aspTypes,
                            awk => \@awkTypes,
                            beta =>  \@betaTypes,
                            c => \@cTypes,
                            cpp => \@cTypes,
                            cs => \@csTypes,
                            cobol => \@cobolTypes, 
                            eiffel => \@eiffelTypes, 
                            erlang => \@erlangTypes, 
                            fortran => \@fortranTypes, 
                            html => \@htmlTypes, 
                            java => \@javaTypes, 
                            javascript => \@javascriptTypes, 
                            lisp => \@lispTypes, 
                            lua => \@luaTypes, 
                            make => \@makeTypes,
                            pascal => \@pascalTypes, 
                            perl => \@perlTypes,
                            php => \@phpTypes, 
                            python => \@pythonTypes,
                            rexx => \@rexxTypes, 
                            ruby => \@rubyTypes,
                            scheme => \@schemeTypes, 
                            sh => \@shTypes, 
                            slang => \@slangTypes, 
                            sml => \@smlTypes, 
                            sql => \@sqlTypes, 
                            tcl => \@tclTypes,
                            vera => \@veraTypes, 
                            verilog => \@verilogTypes, 
                            Vim => \@vimTypes,
                            yacc => \@yaccTypes ) unless(%typeMap);

  # create a subtype hash, much like the typeMap.  This will list what
  # sub-types to display, so for example, C struct types will only have it's
  # "m" member list checked which will list the fields of that struct, while
  # namespaces can have all of the types listed in the @cType array.
  my %adaSubTypes  = ( i => \@adaTypes,
                       t => [ [ "c", "" ],
                              [ "l", "" ],
                              [ "a", "- Discriminants" ] ],
                       u => [ [ "c", "" ],
                              [ "l", "" ],
                              [ "a", "- Discriminants" ] ],
                       P => \@adaTypes,
                       p => \@adaTypes,
                       R => \@adaTypes,
                       r => \@adaTypes,
                       K => \@adaTypes,
                       k => \@adaTypes,
                       O => \@adaTypes,
                       o => \@adaTypes,
                       E => \@adaTypes,
                       e => \@adaTypes,
                       y => \@adaTypes );

  my %cSubTypes  = ( f => [ [ "l", "" ] ],
                     s => [ [ "m", "" ] ],
                     u => [ [ "m", "" ] ],
                     g => [ [ "e", "" ] ],
                     c => \@cTypes,
                     n => \@cTypes );

  our %subTypeMap : unique = ( ada => \%adaSubTypes,
                               c => \%cSubTypes,
                               cpp => \%cSubTypes ) unless(%subTypeMap);

  my $success = 0;
  my $value = 0;

  # Disable any languages which the user wants disabled
  foreach my $key (keys %typeMap) {
    ($success, $value) = VIM::Eval("exists('g:TagsParserDisableLang_$key')");
    delete $typeMap{$key} if ($success == 1 and $value == 1);
  }

  # Lastly, remove any headings that the user wants explicitly disabled
  foreach my $key (keys %typeMap) {
    my $typeRef;

    # now remove any unwanted types, start at the end of the list so that we
    # don't mess things up by deleting entries and changing the length of the
    # array
    for (my $i = @{$typeMap{$key}} - 1; $typeRef = $typeMap{$key}[$i]; $i--) {
      ($success, $value) = VIM::Eval("exists('g:TagsParserDisableType_" .
        $key . "_" . $typeRef->[0] . "')");
      splice(@{$typeMap{$key}}, $i, 1) if ($success == 1 and $value == 1);
    }
  }

  our %typeMapHeadingFold : unique = ( ) unless(%typeMapHeadingFold);

  # build up a list of any headings that the user wants to be automatically
  # folded
  foreach my $key (keys %typeMap) {
    my $typeRef;

    # loop through the headings, and add the actual heading pattern to the
    # heading fold structure
    for (my $i = 0; $typeRef = $typeMap{$key}[$i]; $i++) {
      ($success, $value) = VIM::Eval("exists('g:TagsParserFoldHeading_" .
        $key . "_" . $typeRef->[0] . "')");
      push(@{$typeMapHeadingFold{$key}}, $typeRef->[1]) if
        ($success == 1 and $value == 1);
    }
  }

  # Init the list of supported filetypes
  VIM::DoCommand "let s:supportedFileTypes = '" .
    join('$\|^', keys %typeMap) . "'";
  VIM::DoCommand "let s:supportedFileTypes = '^' . s:supportedFileTypes . '\$'";

PerlFunc
endfunction
" >>>

call <SID>TagsParserPerlInit()
" >>>

" Functions

" TagsParserPerformOp - Checks that The current file is in the tag path <<<
" Based on the input, it will either open the tag window or tag the file.
" For either op, it will make sure that the current file is within the
" g:TagsParserTagsPath path, and then perform some additional checks based on
" the operation it is supposed to perform
function! <SID>TagsParserPerformOp(op, file)
  if a:file == ""
    let l:pathName = expand("%:p:h")
    let l:fileName = expand("%:t")
    let l:curFile = expand("%:p")
  else
    let l:pathName = fnamemodify(a:file, ":p:h")
    let l:fileName = fnamemodify(a:file, ":t")
    let l:curFile = fnamemodify(a:file, ":p")
  endif

  "Make sure that the file we are working on is _not_ a directory
  if isdirectory(l:curFile)
    return
  endif

  "before we check to see if this file is in within TagsParserTagsPath, do the 
  "simple checks to see if this file name and/or path meet the include or
  "exclude criteria
  "The general logic here is, if the pattern is not empty (therefore not
  "disabled), and an exclude pattern matches, or an include pattern fails to 
  "match, return early.
  if (g:TagsParserDirExcludePattern != "" && l:pathName =~ g:TagsParserDirExcludePattern) || (g:TagsParserFileExcludePattern != "" && l:fileName =~ g:TagsParserFileExcludePattern) || (g:TagsParserDirIncludePattern != "" && l:pathName !~ g:TagsParserDirIncludePattern) || (g:TagsParserFileIncludePattern != "" && l:fileName !~ g:TagsParserFileIncludePattern)
    return
  endif
  if exists("g:TagsParserTagsPath")
    let l:tagPathFileMatch = globpath(g:TagsParserTagsPath, l:fileName)
  
    " Put the path, and file into lowercase if this is windows... Since 
    " windows filenames are case-insensitive.
    if has('win32')
      let l:curFile = tolower(l:curFile)
      let l:tagPathFileMatch = tolower(l:tagPathFileMatch)
    endif

    echo l:tagPathFileMatch
    echo l:curFile
    " See if the file is within the current path
    if stridx(l:tagPathFileMatch, l:curFile) != -1
      if a:op == "tag"
        call <SID>TagsParserTagFile(a:file)
      elseif a:op == "open" && g:TagsParserAutoOpenClose == 1 && filereadable(l:pathName . "/.tags/" .  substitute(l:fileName, " ", "_", "g") . ".tags") && &filetype =~ s:supportedFileTypes
        call <SID>TagsParserOpenTagWindow()
      endif
    endif
  endif
endfunction
" >>>
" TagsParserTagFile - Runs tags on a file and names The tag file <<<
" this function will run Ctags for a file and write it to
" ./.tags/<file>.tags it will also create the ./.tags directory if it doesn't
" exist
function! <SID>TagsParserTagFile(file)
  "if the file argument is empty, make it the current file with fully
  "qualified path
  if a:file == ""
    let l:fileName = expand("%:p")

    "gather any user options that may be defined
    if exists("g:TagsParserCtagsOptions_{&filetype}")
      let l:userOptions = g:TagsParserCtagsOptions_{&filetype}
    else
      let l:userOptions = ""
    endif
  else
    let l:fileName = a:file
    let l:userOptions = ""
  endif

  "cleanup the tagfile, regular file and directory names, we have to replace
  "spaces in the actual file name with underscores for the tag file, or else
  "the sort option throws an error for some reason
  let l:baseDir = substitute(fnamemodify(l:fileName, ":h"), '\', '/', 'g')
  let l:tagDir = substitute(fnamemodify(l:fileName, ":h") . "/.tags", '\', '/', 'g')
  let l:tagFileName = substitute(fnamemodify(l:fileName, ":h") . "/.tags/" . fnamemodify(l:fileName, ":t") . ".tags", '\', '/', 'g')
  let l:fileName = substitute(l:fileName, '\', '/', 'g')

  "make the .tags directory if it doesn't exist yet
  if !isdirectory(l:tagDir)
    exe system("mkdir \"" . l:tagDir . "\"")
    let l:noTagFile = "true"
  elseif !filereadable(l:tagFileName)
    let l:noTagFile = "true"
  else 
    let l:noTagFile = "false"
  endif
  
  "if we are in the C:/WINDOWS/SYSTEM32 dir, change to C.  Odd things seem to
  "happen if we are in the system32 directory
  if has('win32') && getcwd() ==? 'C:\WINDOWS\SYSTEM32'
    let s:cwdChanged = 1
    cd C:\
  else
    let s:cwdChanged = 0
  endif

  "now run the tags program
  exec system(g:TagsParserTagsProgram . " -f \"" . l:tagFileName . "\" " . g:TagsParserCtagsOptions . " " . l:userOptions . " --format=2 --excmd=p --fields=+nS --sort=yes --tag-relative=yes \"" . l:fileName . "\"")

  if s:cwdChanged == 1
    cd C:\WINDOWS\SYSTEM32
  endif

  if filereadable(l:tagFileName)
    let l:tagFileExists = "true"
  else
    let l:tagFileExists = "false"
  endif

  "if this file did not have a .tags/*.tags file up until this point and
  "now it does call <SID>TagsParserExpandTagsPath to get the new file included
  if l:noTagFile == "true" && l:tagFileExists == "true"
    call <SID>TagsParserExpandTagsPath()
  endif
endfunction
" >>>
" TagsParserExpandTagsPath - Expands a directory into a list of tags <<< 
" This will expand The g:TagsParserTagsPath directory list into valid tag
" files
function! <SID>TagsParserExpandTagsPath()
  if !exists("s:OldTagsPath")
    let s:OldTagsPath = &tags
  endif

  if exists("g:TagsParserTagsPath")
    let &tags = join(split(globpath(g:TagsParserTagsPath, '/.tags/*.tags'), '\n'), ",") . "," . s:OldTagsPath
  endif
endfunction
" >>>
" TagsParserSetupDirectoryTags - creates tags for all files in this dir <<<
" This takes a directory as a parameter and creates tag files for all files
" under this directory based on The same include/exclude rules that are used
" when a file is written out.  Except that this function does not need to
" follow the TagsParserPath rules.
function! <SID>TagsParserSetupDirectoryTags(dir)
  "if the TagsParserOff flag is set, print out an error and do nothing
  if g:TagsParserOff != 0
    echomsg "TagsParser cannot tag files in this directory because plugin is turned off"
    return
  endif

  "make sure that a:dir does not contain \\ but contains /
  let l:dir = substitute(expand(a:dir), '\', '/', "g")

  if !isdirectory(l:dir)
    echomsg "Directory provided : " . l:dir . " is not a valid directory"
    return
  endif

  "find all files in this directory and all subdirectories
  let l:fileList = globpath(l:dir . '/**,' . l:dir, '*')

  "now parse those into separate files using Perl and then call the
  "TagFile for each file to give it a tag list
perl << PerlFunc
  use strict;
  use warnings;
  no warnings 'redefine';

  my ($success, $files) = VIM::Eval('l:fileList');
  die "Failed to access list of files to tag" if !$success; 

  foreach my $file (split(/\n/, $files)) {
    VIM::DoCommand "call <SID>TagsParserPerformOp('tag', '" . $file . "')";
  }
PerlFunc
endfunction
" >>>
" TagsParserDisplayTags - This will display The tags for the current file <<<
function! <SID>TagsParserDisplayTags()
  "For some reason the ->Append(), ->Set() and ->Delete() functions don't
  "work unless the Perl buffer object is the current buffer... So, change
  "to the tags buffer.
  let l:tagBufNum = bufnr(g:TagsParserWindowName)
  if l:tagBufNum == -1
    return
  endif

  let l:curBufNum = bufnr("%")

  "now change to the tags window if the two buffers are not the same
  if l:curBufNum != l:tagBufNum
    "if we were not originally in the tags window, we need to save the
    "filetype before we move, otherwise the calling function will have saved
    "it for us
    let s:origFileType = &filetype
    let s:origFileName = expand("%:t")
    let s:origFileTagFileName = expand("%:p:h") . "/.tags/" . expand("%:t") . ".tags"
    let s:origWinNum = winnr()
    exec bufwinnr(l:tagBufNum) . "wincmd w"
  endif

  "before we start drawing the tags window, check for the update flag, and
  "make sure that the filetype we are attempting to display is supported
  if s:tagsDataUpdated == 0 && s:lastFileDisplayed == s:origFileName ||
        \ s:origFileType !~ s:supportedFileTypes
    "we must return to the previous window before we can just exit
    if l:curBufNum != l:tagBufNum
      exec s:origWinNum . "wincmd w"
    endif

    return
  endif

  "before we start editing the contents of the tags window we need to make
  "sure that the tags window is modifiable
  setlocal modifiable

perl << PerlFunc
  use strict;
  use warnings;
  no warnings 'redefine';

  our %typeMap : unique unless (%typeMap);
  our %subTypeMap : unique unless (%subTypeMap);

  # verify that we are able to display the correct file type
  my ($success, $kind) = VIM::Eval('s:origFileType');
  die "Failed to access filetype" if !$success;

  # get the name of the tag file for this file
  ($success, my $tagFileName) = VIM::Eval('s:origFileTagFileName');
  die "Failed to access tag file name ($tagFileName)" if !$success;

  # make sure that %tags is created (or referenced)
  our %tags : unique unless (%tags);

  # temp array to store our tag info... At the end of the file we will check
  # to see if this is different than the globalPrintData, if it is we update
  # the screen, if not then we do nothing so as to maintain any folded sections
  # the user has created.
  my @printData = ( );

  my $printLevel = 0;

  # get the name of the tag file for this file
  ($success, my $fileName) = VIM::Eval('s:origFileName');
  die "Failed to access file name ($fileName)" if !$success;

  # get the sort type flag
  ($success, my $sortType) = VIM::Eval('g:TagsParserSortType');
  die "Failed to access sort type ($sortType)" if !$success;

  # check on how we should display the tags
  ($success, my $dispSig) = VIM::Eval('g:TagsParserDisplaySignature');
  die "Failed to access display signature flag" if !$success;

  sub DisplayEntry {
    my $entryRef = shift(@_);
    my $localPrintLevel = shift(@_);

    # set the display string, tag or signature
    my $dispString;
    if ($dispSig == 1) {
      $dispString = $entryRef->{"pattern"};

      # remove all whitespace from the beginning and end of the display string
      $dispString =~ s/^\s*(.*)\s*$/$1/;
    }
    else {
      $dispString = $entryRef->{"tag"};
    }

    # each tag must have a {{{ at the end of it or else it could mess with the
    # folding... Since there are no end folds each tag must have a fold marker
    push @printData, [ ("\t" x $localPrintLevel) . $dispString .
      " {{{" . ($localPrintLevel + 1), $entryRef ];

    # now print any members there might be
    if (defined($entryRef->{"members"}) and
        defined($subTypeMap{$kind}{$entryRef->{"type"}})) {
      $localPrintLevel++;
      # now print any members that this entry may have, only
      # show types which make sense, so for a "s" entry only
      # display "m", this is based on the subTypeMap data
      foreach my $subTypeRef (@{$subTypeMap{$kind}{$entryRef->{"type"}}}) {
        # for each entry in the subTypeMap for this particular
        # entry, check if there are any entries, if there are print them
        if (defined $entryRef->{"members"}{$subTypeRef->[0]}) {
          # display a header (if one exists)
          if ($subTypeRef->[1] ne "") {
            push @printData, [ ("\t" x $localPrintLevel) . $subTypeRef->[1] .
              " {{{" . ($localPrintLevel + 1) ];
            $localPrintLevel++;
          }
       
          # display the data for this sub type, sort them properly based
          # on the global flag
          if ($sortType eq "alpha") {
            foreach my $member (sort { $a->{"tag"} cmp $b->{"tag"} }
              @{$entryRef->{"members"}{$subTypeRef->[0]}}) {
              DisplayEntry($member, $localPrintLevel);
            }
          }
          else {
            foreach my $member (sort { $a->{"line"} <=> $b->{"line"} }
              @{$entryRef->{"members"}{$subTypeRef->[0]}}) {
              DisplayEntry($member, $localPrintLevel);
            }
          }
       
          # reduce the print level if we increased it earlier
          # and print a fold end marker
          if ($subTypeRef->[1] ne "") {
            $localPrintLevel--;
          }
        }
      }
      $localPrintLevel--;
    }
  }

  # at the very top, print out the filename and a blank line
  push @printData, [ "$fileName {{{" . ($printLevel + 1) ];
  push @printData, [ "" ];
  $printLevel++;

  foreach my $ref (@{$typeMap{$kind}}) {
    # verify that there are any entries defined for this particular tag
    # type before we start trying to print them and that they don't have a
    # parent tag.

    my $printTopLevelType = 0;
    foreach my $typeCheckRef (@{$tags{$tagFileName}{$ref->[0]}}) {
      $printTopLevelType = 1 if !defined($typeCheckRef->{"parent"});
    }
     
    if ($printTopLevelType == 1) {
      push @printData, [ ("\t" x $printLevel) . $ref->[1] . " {{{" .
        ($printLevel + 1) ] ;
    
      $printLevel++;
      # now display all the tags for this particular type, and sort them
      # according to the sortType
      if ($sortType eq "alpha") {
        foreach my $tagRef (sort { $a->{"tag"} cmp $b->{"tag"} }
          @{$tags{$tagFileName}{$ref->[0]}}) {
          unless (defined $tagRef->{"parent"}) {
            DisplayEntry($tagRef, $printLevel);
          }
        }
      }
      else {
        foreach my $tagRef (sort { $a->{"line"} <=> $b->{"line"} }
          @{$tags{$tagFileName}{$ref->[0]}}) {
          unless (defined $tagRef->{"parent"}) {
            DisplayEntry($tagRef, $printLevel);
          }
        }
      }
      $printLevel--;

      # between each listing put a line
      push @printData, [ "" ];
    }
  }

  # this hash will be used to keep all of the data referenceable... So that we
  # will be able to print the correct information, reach that info when the tag
  # is to be selected, and find the current tag that the cursor is on in the
  # main window
  our @globalPrintData : unique = ( ) unless(@globalPrintData);

  # check the last file displayed... If it is blank then this is a forced
  # update
  ($success, my $lastFileDisplayed) = VIM::Eval('s:lastFileDisplayed');
  die "Failed to access last file displayed" if !$success;

  # check to see if the data has changed
  my $update = 1;
  if (($lastFileDisplayed ne "") and ($#printData == $#globalPrintData)) {
    $update = 0;
    for ( my $index = 0; $index <= $#globalPrintData; $index++ ) {
      if ($printData[$index][0] ne $globalPrintData[$index][0]) {
        $update = 1;
      }
      # no matter if the display data changed or not, make sure to assign the
      # tag reference to the global data... Otherwise things like line numbers
      # may have changed and the tag window would not have the proper data
      $globalPrintData[$index][1] = $printData[$index][1];
    }
  }

  # if the data did not change, do nothing and quit
  if ($update == 1) {
    # set the globalPrintData array to the new print data contents
    @globalPrintData = @printData;

    # first clean the window
    $main::curbuf->Delete(1, $main::curbuf->Count());

    # set the first line
    $main::curbuf->Set(1, "");

    # append the rest of the data into the window, if this line looks
    # frightening, do a "perldoc perllol" and look at the Slices section
    $main::curbuf->Append(1, map { $printData[$_][0] } 0 .. $#printData);
  }

  # if the fold level is not set, go through the window now and fold any
  # tags that have members
  ($success, my $foldLevel) = VIM::Eval('exists("g:TagsParserFoldLevel")');
  $foldLevel = -1 if($success == 0 || $foldLevel == 0);

  our %typeMapHeadingFold : unique = ( ) unless(%typeMapHeadingFold);

  FOLD_LOOP:
  for (my $index = 0; my $line = $globalPrintData[$index]; $index++) {
    # if this is a tag that has a parent and members, fold it
    if (($foldLevel == -1) and (defined $line->[1]) and
        (defined $line->[1]{"members"}) and (defined $line->[1]{"parent"})) {
      VIM::DoCommand("if foldclosed(" . ($index + 2) . ") == -1 | " .
                     ($index + 2) . "foldclose | endif");
    }
    # we should fold all tags which only have members with empty headings
    elsif (($foldLevel == -1) and (defined $line->[1]{"members"})) {
      foreach my $memberKey (keys %{$line->[1]{"members"}}) {
        foreach my $possibleType (@{$subTypeMap{$kind}{$line->[1]{"type"}}}) {
          # immediately skip to the next loop iteration if we find that a
          # member exists for this tag which contains a non-empty heading
          next FOLD_LOOP if (($memberKey eq $possibleType->[0]) and
                             ($possibleType->[1] ne ""));
        }
      }

      # if we made it this far then this tag should be folded
      VIM::DoCommand("if foldclosed(" . ($index + 2) . ") == -1 | " .
                     ($index + 2) . "foldclose | endif");
    }
    # lastly, if this is a heading which has been marked for folding, fold it
    elsif ((defined $typeMapHeadingFold{$kind}) and
           (not defined $line->[1]) and ($line->[0] =~ /^\s+- .* {{{\d+$/)) {
      foreach my $heading (@{$typeMapHeadingFold{$kind}}) {
        VIM::DoCommand("if foldclosed(" . ($index + 2) . ") == -1 | " .
                       ($index + 2) . "foldclose | endif")
          if ($line->[0] =~ /^\s+$heading {{{\d+$/);
      }
    }
  }
PerlFunc

  "before we go back to the previous window, mark this one as not
  "modifiable, but only if this is currently the tags window
  setlocal nomodifiable

  "mark the update flag as false, and the last file we displayed as what we
  "just worked through
  let s:tagsDataUpdated = 0
  let s:lastFileDisplayed = s:origFileName

  "mark the last tag selected as not folded so accidental folding does not
  "occur
  let s:matchedTagWasFolded = 0

  "go back to the window we were in before moving here, if we were not
  "originally in the tags buffer
  if l:curBufNum != l:tagBufNum
    exec s:origWinNum . "wincmd w"

    if g:TagsParserHighlightCurrentTag == 1
      call <SID>TagsParserHighlightTag(1)
    endif
  endif
endfunction
" >>>
" TagsParserParseCurrentFile - parses The tags file for the current file <<<
" This takes the current file, parses the tag file (if it has not been
" parsed yet, or the tag file has been updated), and saves it into a global
" Perl hash struct for use by the function which prints out the data
function! <SID>TagsParserParseCurrentFile()
  "get the name of the tag file to parse, for the tag file name itself,
  "replace any spaces in the original filename with underscores
  let l:tagFileName = expand("%:p:h") . "/.tags/" . expand("%:t") . ".tags"

  "make sure that the tag file exists before we start this
  if !filereadable(l:tagFileName)
    return
  endif
  
perl << PerlFunc
  use strict;
  use warnings;
  no warnings 'redefine';

  use File::stat;

  # use local to keep %tags available for other functions
  our %tags : unique unless (%tags);
  our %tagMTime : unique unless (%tagMTime);
  our %tagsByLine : unique unless(%tagsByLine);
  
  # get access to the tag file and check it's last modify time
  my ($success, $tagFile) = VIM::Eval('l:tagFileName');
  die "Failed to access tag file variable ($tagFile)" if !$success;

  my $tagInfo = stat($tagFile);
  die "Failed to stat $tagFile" if !$tagInfo;

  # initialize the last modify time if it has not been accessed yet
  $tagMTime{$tagFile} = 0 if !defined($tagMTime{$tagFile});

  # if this file has been tagged before and the tag file has not been
  # updated, just exit
  if ($tagInfo->mtime <= $tagMTime{$tagFile}) {
    VIM::DoCommand "let s:tagsDataUpdated = 0";
    return;
  }
  $tagMTime{$tagFile} = $tagInfo->mtime;
  VIM::DoCommand "let s:tagsDataUpdated = 1";

  # if the tag entries are defined already for this file, delete them now
  delete $tags{$tagFile} if defined($tags{$tagFile});

  # open up the tag file and read the data
  open(TAGFILE, "<", $tagFile) or die "Failed to open tagfile $tagFile";
  while(<TAGFILE>) {
    next if /^!_TAG.*/;
    # process the data
    chomp;

    # split the stuff around the pattern with tabs, and remove the pattern
    # using the special separator ;" character sequence to guard against the
    # possibility of embedded tabs in the pattern
    my ($tag, $file, $rest) = split(/\t/, $_, 3);
    (my $pattern, $rest) = split(/;"\t/, $rest, 2);
    my ($type, $fields) = split(/\t/, $rest, 2);

    # cleanup pattern to remove the / /;" from the beginning and end of the
    # tag search pattern, the hard part is that sometimes the $ may not be at
    # the end of the pattern
    if ($pattern =~ m|/\^(.*)\$/|) {
      $pattern = $1;
    }
    else {
      $pattern =~ s|/\^(.*)/|$1|;
    }

    # there may be some escaped /'s in the pattern, un-escape them
    $pattern =~ s|\\/|/|g;

    # if the " file:" tag is here, remove it, we want it to be in the file
    # since Vim can use the file: field to know if something is file static,
    # but we don't care about it much for this script, and it messes up my
    # hash creation
    $fields =~ s/\tfile://;

    push @{$tags{$tagFile}{$type}}, { "tag", $tag, "type", $type, "pattern",
                                      $pattern, split(/\t|:/, $fields) };
  }
  close(TAGFILE);

  # before worrying about anything else, make up a line number-oriented hash of
  # the tags, this will make finding a match, or what the current tag is easier
  delete $tagsByLine{$tagFile} if defined($tagsByLine{$tagFile});

  while (my ($key, $typeArray) = each %{$tags{$tagFile}}) {
    foreach my $tagEntry (@{$typeArray}) {
      push @{$tagsByLine{$tagFile}{$tagEntry->{"line"}}}, $tagEntry;
    }
  }

  # setup the kind mappings for types that have member-types
  our %adaKinds : unique = ( P => "packspec",
                             p => "package",
                             T => "typespec",
                             t => "type",
                             U => "subspec",
                             u => "subtype",
                             c => "component",
                             l => "literal",
                             V => "varspec",
                             v => "variable",
                             n => "constant",
                             x => "exception",
                             f => "formal",
                             R => "subprogspec",
                             r => "subprogram",
                             K => "taskspec",
                             k => "task",
                             O => "protectspec",
                             o => "protected",
                             E => "entryspec",
                             e => "entry",
                             b => "label",
                             i => "identifier",
                             a => "autovar",
                             y => "annon" ) unless(%adaKinds);
  
  our %cKinds : unique = ( c => "class",
                           g => "enum",
                           n => "namespace",
                           s => "struct",
                           u => "union" ) unless(%cKinds);

  # define the kinds which we can map in a hierarchical fashion
  our %kindMap : unique = ( ada => \%adaKinds,
                            c => \%cKinds,
                            h => \%cKinds,
                            cpp => \%cKinds ) unless(%kindMap);

  ($success, my $kind) = VIM::Eval('&filetype');
  die "Failed to access current file type" if !$success;

  ($success, my $noNestedTags) = VIM::Eval('g:TagsParserNoNestedTags');
  die "Failed to access the nested tag display flag" if !$success;

  # parse the data we just read into hierarchies... If we don't have a
  # kind hash entry for the current file type, just skip the rest of this
  # function
  return if (not defined($kindMap{$kind}) or $noNestedTags == 1);

  # for each key, sort it's entries.  These are the tags for each tag,
  # check for any types which have a scope, and if they do, reference that type
  # to the correct parent type
  #
  # yeah, this loop sucks, but I haven't found a more efficient way to do
  # it yet
  foreach my $key (keys %{$tags{$tagFile}}) {
    foreach my $tagEntry (@{$tags{$tagFile}{$key}}) {
      while (my ($tagType, $tagTypeName) = each %{$kindMap{$kind}}) {
        # search for any member types of the current tagEntry, but only if
        # such a member is defined for the current tag
        if (defined($tagEntry->{$tagTypeName}) and
            defined($tags{$tagFile}{$tagType})) {
          # sort the possible member entries by line number so that when
          # looking for the parent entry we are sure to only get the one who's
          # line is just barely less than the current tag's line
          FIND_PARENT:
          foreach my $tmpEntry (sort { $b->{"line"} <=> $a->{"line"} }
            @{$tags{$tagFile}{$tagType}}) {
            # for the easiest way to do this, only consider tags a match if
            # the line number of the possible parent tag is less than or equal
            # to the line number of the current tagEntry
            if (($tmpEntry->{"tag"} eq $tagEntry->{$tagTypeName}) and
              ($tmpEntry->{"line"} <= $tagEntry->{"line"})) {
              # push a reference to the current tag onto the parent tag's
              # member stack
              push @{$tmpEntry->{"members"}{$key}}, $tagEntry;
              $tagEntry->{"parent"} = $tmpEntry;
              last FIND_PARENT;
            }
          }
        }
      }
    }
  }

  # processing those local vars for C
  if (($kind =~ /c|h|cpp/) and (defined $tags{$tagFile}{"l"}) and
    (defined $tags{$tagFile}{"f"})) {
    # setup a reverse list of local variable references sorted by line
    my @vars = sort { $b->{"line"} <=> $a->{"line"} } @{$tags{$tagFile}{"l"}};

    # sort the functions by reversed line entry... Then we will go through the
    # list of local variables until we find one who's line number exceeds that
    # of the functions.  Then we unshift the array and go to the next function
    FUNC: foreach my $funcRef (sort { $b->{"line"} <=> $a->{"line"} }
      @{$tags{$tagFile}{"f"}}) {
      VAR: while (my $varRef = shift @vars) {
        if ($varRef->{"line"} >= $funcRef->{"line"}) {
          push @{$funcRef->{"members"}{"l"}}, $varRef;
          $varRef->{"parent"} = $funcRef;
          next VAR;
        }
        else {
          unshift(@vars, $varRef);
          next FUNC;
        }
      }
    }
  }
PerlFunc
endfunction
" >>>
" TagsParserOpenTagWindow - Opens up The tag window <<<
function! <SID>TagsParserOpenTagWindow()
  "ignore events while opening the tag window
  let l:oldEvents = &eventignore
  set eventignore=all

  "save the window number and potential tag file name for the current file
  let s:origFileName = expand("%:t")
  let s:origFileTagFileName = expand("%:p:h") . "/.tags/" . expand("%:t") . ".tags"
  let s:origWinNum = winnr()
  "before we move to the new tags window, we must save the type of file
  "that we are currently in
  let s:origFileType = &filetype

  "parse the current file
  call <SID>TagsParserParseCurrentFile()

  "open the tag window
  if !bufloaded(g:TagsParserWindowName)
    if g:TagsParserNoResize == 0
      "track the current window size, so that when we close the tags tab, 
      "if we were not able to resize the current window, that we don't 
      "decrease it any more than we increased it when we opened the tab
      let s:origColumns = &columns
      "open the tag window, + 1 for the split divider
      let &columns = &columns + g:TagsParserWindowSize + 1
      let s:columnsAdded = &columns - s:origColumns
      let s:newColumns = &columns
    endif

    exec s:TagsWindowPosition . " " . g:TagsParserWindowSize  . " split " .
          \ g:TagsParserWindowName

    "settings to keep the buffer from interfering with anything else
    setlocal nonumber
    setlocal nobuflisted
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete

    if v:version >= 700
      setlocal nospell
    endif

    "formatting related settings
    setlocal nowrap
    setlocal tabstop=2

    "fold related settings
    if exists('g:TagsParserFoldLevel')
      let l:foldLevelString = 'setlocal foldlevel=' . g:TagsParserFoldLevel
      exec l:foldLevelString
    else
      "if the foldlevel is not defined, default it to something large so that
      "the default folding method takes over
      setlocal foldlevel=100
    endif

    "only turn the fold column on if the disabled flag is not set
    if g:TagsParserFoldColumnDisabled == 0
      setlocal foldcolumn=3
    endif

    setlocal foldenable
    setlocal foldmethod=marker
    setlocal foldtext=TagsParserFoldFunction()
    setlocal fillchars=fold:\ 

    "if the highlight tag option is on, reduce the updatetime... But not too
    "much because it is global and it could impact overall VIM performance
    if g:TagsParserHighlightCurrentTag == 1
      setlocal updatetime=1000
    endif
    
    "command to go to tag in previous window:
    nmap <buffer> <silent> <CR> :call <SID>TagsParserSelectTag()<CR>
    nmap <buffer> <silent> <2-LeftMouse>
          \ :call <SID>TagsParserSelectTag()<CR>

    "the augroup we are going to setup will override this initial
    "autocommand so stop it from running
    autocmd! TagsParserBufWinEnterWindowNotOpen

    "setup and autocommand so that when you enter a new buffer, the new file is
    "parsed and then displayed
    augroup TagsParserBufWinEnterEvents
      autocmd!
      autocmd WinEnter ?* call <SID>TagsParserStoreWindowID(expand("<afile>"))
      autocmd BufWinEnter ?* call <SID>TagsParserHandleBufWinEnter()
      
      "when a file is written, add an event so that the new tag file is parsed
      "and displayed (if there are updates)
      autocmd BufWritePost ?* call <SID>TagsParserParseCurrentFile() |
            \ call <SID>TagsParserDisplayTags()

      "properly handle the WinLeave event
      autocmd BufWinLeave ?* call <SID>TagsParserHandleBufWinLeave()

      "make sure that we don't accidentally close the Vim session when loading
      "up a new buffer
      autocmd BufAdd * let s:newBufBeingCreated = 1
    augroup end

    "add the event to do the auto tag highlighting if the event is set
    if g:TagsParserHighlightCurrentTag == 1
      augroup TagsParserCursorHoldEvent
        autocmd!
        autocmd CursorHold ?* call <SID>TagsParserHighlightTag(0)
      augroup end
    endif

    if !hlexists('TagsParserFileName')
      hi link TagsParserFileName Underlined
    endif

    if !hlexists('TagsParserTypeName')
      hi link TagsParserTypeName Special 
    endif

    if !hlexists('TagsParserTag')
      hi link TagsParserTag Normal
    endif

    if !hlexists('TagsParserFoldMarker')
      hi link TagsParserFoldMarker Ignore
    endif

    if !hlexists('TagsParserHighlight')
      hi link TagsParserHighlight ToDo
    endif

    "setup the syntax for the tags window
    syntax match TagsParserTag '\(- \)\@<!\S\(.*\( {{{\)\@=\|.*\)'
          \ contains=TagsParserFoldMarker
    syntax match TagsParserFileName '^\w\S*'
    syntax match TagsParserTypeName '^\t*- .*' contains=TagsParserFoldMarker
    syntax match TagsParserFoldMarker '{{{.*\|\s*}}}'
  endif

  "display the tags
  call <SID>TagsParserDisplayTags()

  "go back to the previous window, find the winnr for the buffer, and
  "do a :<N>wincmd w
  exec s:origWinNum . "wincmd w"

  "un ignore events 
  let &eventignore=l:oldEvents
  unlet l:oldEvents
  
  "highlight the current tag (if flag is set)
  if g:TagsParserHighlightCurrentTag == 1
    call <SID>TagsParserHighlightTag(1)
  endif
endfunction
" >>>
" TagsParserCloseTagWindow - Closes The tags window <<<
function! <SID>TagsParserCloseTagWindow()
  "ignore events while opening the tag window
  let l:oldEvents = &eventignore
  set eventignore=all

  "if the window exists, find it and close it
  if bufloaded(g:TagsParserWindowName)
    "save current file winnr
    let l:curWinNum = winnr()

    "save the current tags window size
    let l:tagsWindowSize = winwidth(bufwinnr(g:TagsParserWindowName))
 
    "go to and close the tags window
    exec bufwinnr(g:TagsParserWindowName) . "wincmd w"
    close

    if g:TagsParserNoResize == 0
      "resize the Vim window
      if g:TagsParserWindowSize == l:tagsWindowSize && s:newColumns == &columns
        let &columns = &columns - s:columnsAdded
      else
        "if the window sizes have been changed since the window was opened,
        "attempt to save the new sizes to use later
        let g:TagsParserWindowSize = l:tagsWindowSize
        let &columns = &columns - g:TagsParserWindowSize - 1
      endif
    endif
    
    "now go back to the file we were just in assuming it wasn't the
    "tags window in which case this will simply fail silently
    exec l:curWinNum . "wincmd w"

    "zero out the last file displayed variable so that if the tags window is
    "reopened then the tags should be redrawn
    let s:lastFileDisplayed = ""

    "remove all buffer related autocommands
    autocmd! TagsParserBufWinEnterEvents
    autocmd! TagsParserCursorHoldEvent

    augroup TagsParserBufWinEnterWindowNotOpen
      autocmd BufWinEnter ?* call <SID>TagsParserPerformOp("open")
    augroup end
  endif
  
  "un ignore events 
  let &eventignore=l:oldEvents
  unlet l:oldEvents
endfunction
" >>>
" TagsParserToggle - Will toggle The tags window open or closed <<<
function! <SID>TagsParserToggle()
  "if the TagsParserOff flag is set, print out an error and do nothing
  if g:TagsParserOff != 0
    echomsg "TagsParser window cannot be opened because plugin is turned off"
    return
  elseif g:TagsParserNoTagWindow == 1
    echomsg "TagsParser window cannot be opened because the Tag window has been disabled by the g:TagsParserNoTagWindow variable"
    return
  endif

  "check to see if the tags window is loaded, if it is not, open it, if it
  "is, close it
  if bufloaded(g:TagsParserWindowName)
    "if the tags parser is forced closed, turn off the auto open/close flag
    if g:TagsParserAutoOpenClose == 1
      let g:TagsParserAutoOpenClose = 0
      let s:autoOpenCloseTurnedOff = 1
    endif

    call <SID>TagsParserCloseTagWindow()
  else
    if exists("s:autoOpenCloseTurnedOff") && s:autoOpenCloseTurnedOff == 1
      let g:TagsParserAutoOpenClose = 1
      let s:autoOpenCloseTurnedOff = 0
    endif
    call <SID>TagsParserOpenTagWindow()
  endif
endfunction
" >>>
" TagsParserHandleBufWinEnter - handles The BufWinEnter event <<<
function! <SID>TagsParserHandleBufWinEnter()
  "clear out the new buf flag
  let s:newBufBeingCreated = 0

  "if the buffer we just entered is unmodifiable do nothing and return
  if &modifiable == 0
    return
  endif

  "if the auto open/close flag is set, see if there is a tag file for the
  "new buffer, if there is, call open, otherwise, call close
  if g:TagsParserAutoOpenClose == 1
    let l:tagFileName = expand("%:p:h") . "/.tags/" .
          \ substitute(expand("%:t"), " ", "_", "g") . ".tags"

    if !filereadable(l:tagFileName)
      call <SID>TagsParserCloseTagWindow()
    else
      call <SID>TagsParserOpenTagWindow()
    endif
  else
    "else parse the current file and call display tags
    call <SID>TagsParserParseCurrentFile()
    call <SID>TagsParserDisplayTags()
  endif
endfunction
">>>
" TagsParserHandleBufWinLeave - handles The BufWinLeave event <<<
function! <SID>TagsParserHandleBufWinLeave()
  "if there is only the tags buffer left showing after this window exits,
  "exit VIM
  if g:TagsParserAutoOpenClose == 1 && bufnr("%") != bufnr(g:TagsParserWindowName) && bufloaded(g:TagsParserWindowName) && winbufnr(3) == -1 && s:newBufBeingCreated == 0
    call <SID>TagsParserCloseTagWindow()
    qall
  else
    "if we are unloading the tags window, and the auto open/close flag is on,
    "turn it off
    if bufname("%") == g:TagsParserWindowName
      if g:TagsParserAutoOpenClose == 1
        let g:TagsParserAutoOpenClose = 0
        let s:autoOpenCloseTurnedOff = 1
      endif

      "if the buffer explorer work around is enabled, we don't need to manually
      "close the window here
      if g:TagsParserBufExplWorkAround == 0
        call <SID>TagsParserCloseTagWindow()
      endif
    endif

    "close the tag window when cycling buffers if the buffer explorer work
    "around is enabled
    if g:TagsParserBufExplWorkAround == 1
      call <SID>TagsParserCloseTagWindow()
    endif
  endif
endfunction
">>>
" TagsParserSelectTag - activates a tag (if it is a tag) <<<
function! <SID>TagsParserSelectTag()
  "ignore events while selecting a tag
  let l:oldEvents = &eventignore
  set eventignore=all

  "clear out any previous match
  if s:matchedTagWasFolded == 1
    exec s:matchedTagFoldStart . "," . s:matchedTagFoldEnd . "foldclose"
    let s:matchedTagWasFolded = 0
  endif

  match none

perl << PerlFunc
  use strict;
  use warnings;
  no warnings 'redefine';

  my ($success, $lineNum) = VIM::Eval('line(".")');
  die "Failed to access The current line" if !$success;

  our @globalPrintData : unique unless(@globalPrintData);

  # subtract 2 (1 for the append offset, and 1 because it starts at 0) from
  # the line number to get the proper globalPrintData index
  my $indexNum = $lineNum - 2;

  # if this is a tag, there will be a reference to the correct tag entry in
  # the referenced globalPrintData array
  if (defined $globalPrintData[$indexNum][1]) {
    # if this line is folded, unfold it
    ($success, my $folded) = VIM::Eval("foldclosed($lineNum)");
    die "Failed to verify if $lineNum is folded" if !$success;

    if ($folded != -1) {
      ($success, my $foldEnd) = VIM::Eval("foldclosedend($lineNum)");
      die "Failed to retrieve end of fold for line $lineNum" if !$success;

      VIM::DoCommand "let s:matchedTagFoldStart = $folded";
      VIM::DoCommand "let s:matchedTagFoldEnd = $foldEnd";

      VIM::DoCommand "let s:matchedTagWasFolded = 1";
      VIM::DoCommand $folded . "," . $foldEnd . "foldopen";
    }
    else {
      VIM::DoCommand "let s:matchedTagWasFolded = 0";
    }

    # now match this tag
    VIM::DoCommand 'match TagsParserHighlight /\%' . $lineNum .
      'l\S.*\( {{{\)\@=/';

    # go to the proper window, go the correct line, unfold it (if necessary),
    # move to the correct word (the tag) and finally, set a mark
    VIM::DoCommand 'exec s:origWinNum . "wincmd w"';
    VIM::DoCommand $globalPrintData[$indexNum][1]{"line"};

    # get the current line
    ($success, my $curLine) = VIM::Eval("getline('.')");
    die "Failed to access current line " if !$success;

    # now get the index
    my $position = index $curLine, $globalPrintData[$indexNum][1]{"tag"};

    # move to that column if we got a valid value
    VIM::DoCommand("exec 'normal 0" . $position . "l'") if ($position != -1);

    VIM::DoCommand "if foldclosed('.') != -1 | .foldopen | endif";
    VIM::DoCommand "normal m\'";
  }
  else {
    # otherwise we should just toggle this fold open/closed if the line is
    # actually folded
    VIM::DoCommand "if foldclosed('.') != -1 | .foldopen | else | .foldclose | endif";
  }
PerlFunc

  "un ignore events 
  let &eventignore=l:oldEvents
  unlet l:oldEvents
endfunction
" >>>
" TagsParserHighlightTag - highlights The tag that the cursor is on <<<
function! <SID>TagsParserHighlightTag(resetCursor)
  "if this buffer is unmodifiable, do nothing
  if &modifiable == 0
    return
  endif

  "get the current and tags buffer numbers
  let l:curBufNum = bufnr("%")
  let l:tagBufNum = bufnr(g:TagsParserWindowName)

  "return if the tags buffer is not open or this is the tags window we are
  "currently in
  if l:tagBufNum == -1 || l:curBufNum == l:tagBufNum
    return
  endif

  "yank the word under the cursor into register a, and make sure to place the
  "cursor back in the right position
  exec 'normal ma"ayiw`a'
  
  let l:curWinNum = winnr()
  let l:curPattern = getline(".")
  let l:curLine = line(".")
  let l:curWord = getreg("a")

  "ignore events before changing windows
  let l:oldEvents = &eventignore
  set eventignore=all

  "goto the tags window
  exec bufwinnr(l:tagBufNum) . "wincmd w"
  
  "clear out any previous match
  if s:matchedTagWasFolded == 1
    exec s:matchedTagFoldStart . "," . s:matchedTagFoldEnd . "foldclose"
    let s:matchedTagWasFolded = 0
  endif
  let s:matchedTagLine = 0

  match none

perl << PerlFunc
  use strict;
  use warnings;
  no warnings 'redefine';

  # find the current word and line
  my ($success, $curPattern) = VIM::Eval('l:curPattern');
  die "Failed to access current pattern" if !$success;

  ($success, my $curLine) = VIM::Eval('l:curLine');
  die "Failed to access current line" if !$success;

  # the "normal mayiw`a" command above yanked the word under the cursor into
  # register a
  ($success, my $curWord) = VIM::Eval('l:curWord');
  die "Failed to access current word" if !$success;

  # get the name of the tag file for this file
  ($success, my $tagFileName) = VIM::Eval('s:origFileTagFileName ');
  die "Failed to access file name ($tagFileName)" if !$success;

  our @globalPrintData : unique unless (@globalPrintData);
  our %tagsByLine : unique unless(%tagsByLine);

  my $easyRef = undef;
  my $trueRef = undef;

  # now look up this tag
  if (defined $tagsByLine{$tagFileName}{$curLine}) {
    my $count = 1;
    TRUE_REF_SEARCH:
    foreach my $ref (@{$tagsByLine{$tagFileName}{$curLine}}) {
      if (substr($curPattern, 0, length($ref->{"pattern"})) eq
          $ref->{"pattern"}) {
        if ($curWord eq $ref->{"tag"}) {
          $trueRef = $ref;
          last TRUE_REF_SEARCH;
        }
        else {
          $easyRef = $ref;
        }
      } # if (substr($curPattern, 0, length($ref->{"pattern"})) eq ...
    } # TRUE_REF_SEARCH: ...

    # if we didn't find an exact match go with the default match
    $trueRef = $easyRef if (not defined($trueRef));

    # now we have to find the correct line for this tag in the globalPrintData
    my $index = 0;
    while (my $line = $globalPrintData[$index++]) {
      if (defined $line->[1] and $line->[1] == $trueRef) {
        my $tagLine = $index + 1;
      
        # if this line is folded, unfold it
        ($success, my $folded) = VIM::Eval("foldclosed($tagLine)");
        die "Failed to verify if $tagLine is folded" if !$success;

        if ($folded != -1) {
          ($success, my $foldEnd) = VIM::Eval("foldclosedend($tagLine)");
          die "Failed to retreive end of fold for line $tagLine" if !$success;

          VIM::DoCommand "let s:matchedTagFoldStart = $folded";
          VIM::DoCommand "let s:matchedTagFoldEnd = $foldEnd";

          VIM::DoCommand "let s:matchedTagWasFolded = 1";
          VIM::DoCommand $folded . "," . $foldEnd . "foldopen";
        }
        else {
          VIM::DoCommand "let s:matchedTagWasFolded = 0";
        }

        # now match this tag
        VIM::DoCommand 'match TagsParserHighlight /\%' . $tagLine .
          'l\S.*\( {{{\)\@=/';
     
        # now that the tag has been highlighted, go to the tag and make the line
        # visible, and then go back to the tag line so that the cursor is in the
        # correct place
        VIM::DoCommand $tagLine;
        VIM::DoCommand "exec winline()";
        VIM::DoCommand $tagLine;

        last;
      } # if ($line->[1] == $trueRef) {
    } # while (my $line = $globalPrintData[$index++]) {
  } # if (defined $tagsByLine{$tagFileName}{$curLine}) {
PerlFunc
  
  "before we go back to the previous window... Check if we found a match.  If
  "we did not, and the resetCursor parameter is 1 then move the cursor to the
  "top of the file
  if a:resetCursor == 1 && s:matchedTagLine == 0
    exec 1
    exec winline()
    exec 1
  endif

  "go back to the old window
  exec l:curWinNum . "wincmd w"

  "un ignore events 
  let &eventignore=l:oldEvents
  unlet l:oldEvents

  return
endfunction
">>>
" TagsParserFoldFunction - function to make proper tags for folded tags <<<
function! TagsParserFoldFunction()
  let l:line = getline(v:foldstart)
  let l:tabbedLine = substitute(l:line, "\t", "  ", "g")
  let l:finishedLine = substitute(l:tabbedLine, " {{{.*", "", "")
  let l:numLines = v:foldend - v:foldstart
  return l:finishedLine . " : " . l:numLines . " lines"
endfunction
" >>>
" TagsParserOff - function to turn off all TagsParser functionality <<<
function! <SID>TagsParserOff()
  "only do something if The TagsParser is not off already
  if g:TagsParserOff == 0
    "to turn off the TagsParser, call the TagsParserCloseTagWindow() function,
    "which will uninstall all autocommands except for the default
    "TagsParserAutoCommands group (which is always on) and the
    "TagsParserBufWinEnterWindowNotOpen group (which is on when the window is
    "closed)
    call <SID>TagsParserCloseTagWindow()
    
    autocmd! TagsParserAutoCommands
    autocmd! TagsParserBufWinEnterWindowNotOpen

    "finally, set the TagsParserOff flag to 1
    let g:TagsParserOff = 1
  endif
endfunction
" >>>
" TagsParserOn - function to turn all TagsParser functionality back on <<<
function! <SID>TagsParserOn()
  "only do something if The TagsParser is off
  if g:TagsParserOff != 0 && g:TagsParserNoTagWindow == 0
    augroup TagsParserAutoCommands
      autocmd!
      "setup an autocommand that will expand the path described by
      "g:TagsParserTagsPath into a valid tag path
      autocmd VimEnter * call <SID>TagsParserExpandTagsPath() |
            \ call <SID>TagsParserPerformOp("open")

      "setup an autocommand so that when a file is written to it writes a tag
      "file if it a file that is somewhere within the tags path or the
      "g:TagsParserTagsPath path
      autocmd BufWritePost ?* call <SID>TagsParserPerformOp("tag")
    augroup end

    augroup TagsParserBufWinEnterWindowNotOpen
      autocmd BufWinEnter ?* call <SID>TagsParserPerformOp("open")
    augroup end
  elseif g:TagsParserOff != 0 && g:TagsParserNoTagWindow == 1
    augroup TagsParserAutoCommands
      autocmd!
      "setup an autocommand that will expand the path described by 
      "g:TagsParserTagsPath into a valid tag path
      autocmd VimEnter * call <SID>TagsParserExpandTagsPath()

      "setup an autocommand so that when a file is written to it writes a tag
      "file if it a file that is somewhere within the tags path or the
      "g:TagsParserTagsPath path
      autocmd BufWritePost ?* call <SID>TagsParserPerformOp("tag")
    augroup end
  endif
  let g:TagsParserOff = 0
endfunction
" >>>
" TagsParserCOpen - opens The quickfix window nicely <<<
function! <SID>TagsParserCOpen(...)
  let l:windowClosed = 0

  "if the tag window is open, close it
  if bufloaded(g:TagsParserWindowName) && s:TagsWindowPosition =~ "vertical"
    call <SID>TagsParserCloseTagWindow()
    let l:windowClosed = 1
  endif

  "get the current window number
  let l:curBuf = bufnr("%")

  "now open the quickfix window
  if(a:0 == 1)
    exec "copen " . a:1
  else
    exec "copen"
  endif

  "go back to the original window
  exec bufwinnr(l:curBuf) . "wincmd w"

  "go to the first error
  exec "cfirst"

  "reopen the tag window if necessary
  if l:windowClosed == 1
    call <SID>TagsParserOpenTagWindow()
  endif
endfunction
" >>>
" TagsParserCWindow - opens The quickfix window nicely <<<
function! <SID>TagsParserCWindow(...)
  let l:windowClosed = 0

  "if the tag window is open, close it
  if bufloaded(g:TagsParserWindowName) && s:TagsWindowPosition =~ "vertical"
    call <SID>TagsParserCloseTagWindow()
    let l:windowClosed = 1
  endif

  "get the current window number
  let l:curBuf = bufnr("%")

  "now open the quickfix window
  if(a:0 == 1)
    exec "cwindow " . a:1
  else
    exec "cwindow"
  endif
  
  "go back to the original window, if we actually changed windows
  if l:curBuf != bufnr("%")
    exec bufwinnr(l:curBuf) . "wincmd w"

    "go to the first error
    exec "cfirst"
  endif

  "reopen the tag window if necessary
  if l:windowClosed == 1
    call <SID>TagsParserOpenTagWindow()
  endif
endfunction
" >>>
" TagsParserStoreWindowID - stores The new window ID of the current file <<<
function! <SID>TagsParserStoreWindowID(bufName)
  if a:bufName == s:origFileName && winnr() != s:origWinNum
    let s:origWinNum = winnr()
  endif
endfunction
" >>>

let &cpo = s:cpoSave
unlet s:cpoSave

" vim:ft=Vim:fdm=marker:ff=unix:wrap:ts=2:sw=2:sts=2:sr:et:fmr=<<<,>>>:fdl=0
