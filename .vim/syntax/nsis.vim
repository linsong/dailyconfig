" Vim syntax file
" Language:	NSIS script, for version of NSIS 2.45 and later
" Maintainer:	Alex Jakushev <Alex.Jakushev@kemek.lt>
" Maintainer:	Chris Morgan <chris.morganiser@gmail.com>
" Last Change:	2009 November 23
" Version:      2.45-2

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore


"Scripting Reference: (4)
"Comments: (4.1.2)
syn keyword nsisTodo	todo attention note fixme readme
" The next two lines are because a single ; or # at the end must be caught and I'm not sure if it can be done otherwise.
syn region nsisComment	start=";$"  end="" contains=nsisTodo
syn region nsisComment	start="#$"  end="" contains=nsisTodo
syn region nsisComment	start=";"  end="[^\\]$" contains=nsisTodo
syn region nsisComment	start="#"  end="[^\\]$" contains=nsisTodo
syn region nsisComment	start="/\*" end="\*/" contains=nsisTodo
"Plugins: (4.1.3)
syn match nsisPluginCall	"^\s*\S\{-}::\S\+"
"Strings: (4.1.5)
syn region nsisString	start=/"/ skip=/'\|`/ end=/"/ contains=nsisPreprocSubst,nsisLangSubst,nsisUserVar,nsisSysVar,nsisConstVar
syn region nsisString	start=/'/ skip=/"\|`/ end=/'/ contains=nsisPreprocSubst,nsisLangSubst,nsisUserVar,nsisSysVar,nsisConstVar
syn region nsisString	start=/`/ skip=/"\|'/ end=/`/ contains=nsisPreprocSubst,nsisLangSubst,nsisUserVar,nsisSysVar,nsisConstVar
syn match nsisConstVar	"$\\\""
"Numbers: (4.1.6)
syn match nsisNumber		"\<[^0]\d*\>" " decimal
syn match nsisNumber		"\<0x\x\+\>"  " hex
syn match nsisNumber		"\<0\o*\>"    " octal
syn match nsisNumber		"\<\x\{6}\>"  " hex colour


"Variables: (4.2)
"User Variables: (4.2.1.1)
syn match nsisVarCommand	"^\s*\zsVar"
"Other Writable Variables: (4.2.2)
syn match nsisUserVar		"$\d"
syn match nsisUserVar		"$R\d"
syn match nsisSysVar		"$INSTDIR"
syn match nsisSysVar		"$OUTDIR"
syn match nsisSysVar		"$CMDLINE"
syn match nsisSysVar		"$LANGUAGE"
"Constants: (4.2.3)
syn match nsisConstVar		"$PROGRAMFILES"
syn match nsisConstVar		"$PROGRAMFILES32"
syn match nsisConstVar		"$PROGRAMFILES64"
syn match nsisConstVar		"$COMMONFILES"
syn match nsisConstVar		"$COMMONFILES32"
syn match nsisConstVar		"$COMMONFILES64"
syn match nsisConstVar		"$DESKTOP"
syn match nsisConstVar		"$EXEDIR"
syn match nsisConstVar		"$EXEFILE"
syn match nsisConstVar		"$EXEPATH"
syn match nsisConstVar		"${NSISDIR}"
syn match nsisConstVar		"$WINDIR"
syn match nsisConstVar		"$SYSDIR"
syn match nsisConstVar		"$TEMP"
syn match nsisConstVar		"$STARTMENU"
syn match nsisConstVar		"$SMPROGRAMS"
syn match nsisConstVar		"$SMSTARTUP"
syn match nsisConstVar		"$QUICKLAUNCH"
syn match nsisConstVar		"$DOCUMENTS"
syn match nsisConstVar		"$SENDTO"
syn match nsisConstVar		"$RECENT"
syn match nsisConstVar		"$FAVORITES"
syn match nsisConstVar		"$MUSIC"
syn match nsisConstVar		"$PICTURES"
syn match nsisConstVar		"$VIDEOS"
syn match nsisConstVar		"$NETHOOD"
syn match nsisConstVar		"$FONTS"
syn match nsisConstVar		"$TEMPLATES"
syn match nsisConstVar		"$APPDATA"
syn match nsisConstVar		"$LOCALAPPDATA"
syn match nsisConstVar		"$PRINTHOOD"
syn match nsisConstVar		"$INTERNET_CACHE"
syn match nsisConstVar		"$COOKIES"
syn match nsisConstVar		"$HISTORY"
syn match nsisConstVar		"$PROFILE"
syn match nsisConstVar		"$ADMINTOOLS"
syn match nsisConstVar		"$RESOURCES"
syn match nsisConstVar		"$RESOURCES_LOCALIZED"
syn match nsisConstVar		"$CDBURN_AREA"
syn match nsisConstVar		"$HWNDPARENT"
syn match nsisConstVar        "$PLUGINSDIR"
"Constants Used In Strings: (4.2.4)
syn match nsisConstVar		"$\$"
syn match nsisConstVar		"$\\r"
syn match nsisConstVar		"$\\n"
syn match nsisConstVar		"$\\t"

"Labels: (4.3)
"This isn't working for single-character labels; I suspect a later instruction is interfering.
syn match nsisLocalLabel	"^\s*\zs[^-+!$0-9.;#][^;#: 	]\{-}:\($\|\s\+\)"
syn match nsisGlobalLabel	"^\s*\zs\.[^-+!$0-9][^;#: 	]\{-}:\($\|\s\+\)"


"Compile Time Commands: (5)
"Compiler Utility Commands: (5.1)
syn match nsisInclude		"^\s*\zs!include\>"
syn match nsisInclude		"^\s*\zs!addincludedir\>"
syn match nsisInclude		"^\s*\zs!addplugindir\>"
syn match nsisSystem		"^\s*\zs!appendfile\>"
syn match nsisSystem		"^\s*\zs!cd\>"
syn match nsisSystem		"^\s*\zs!delfile\>"
syn match nsisSystem		"^\s*\zs!echo\>"
syn match nsisSystem		"^\s*\zs!error\>"
syn match nsisSystem		"^\s*\zs!execute\>"
syn match nsisSystem		"^\s*\zs!packhdr\>"
syn match nsisSystem		"^\s*\zs!system\>"
syn match nsisSystem		"^\s*\zs!tempfile\>"
syn match nsisSystem		"^\s*\zs!warning\>"
syn match nsisSystem		"^\s*\zs!verbose\>"


"Predefines: (5.2)
"Nothing to add in here


"Read Environment Variables: (5.3)
syn match nsisPreprocSubst	"$%.\{-}%"


"Conditional Compilation: (5.4)
syn match nsisPreprocSubst	"${.\{-}}" contains=nsisLogicLibKeyword
syn match nsisDefine		"^\s*\zs!define\>"
syn match nsisDefine		"^\s*\zs!undef\>"
syn match nsisPreCondit		"^\s*\zs!ifdef\>"
syn match nsisPreCondit		"^\s*\zs!ifndef\>"
syn match nsisPreCondit		"^\s*\zs!if\>"
syn match nsisPreCondit		"^\s*\zs!ifmacrodef\>"
syn match nsisPreCondit		"^\s*\zs!ifmacrondef\>"
syn match nsisPreCondit		"^\s*\zs!else\>"
syn match nsisPreCondit		"^\s*\zs!endif\>"
syn match nsisMacro			"^\s*\zs!insertmacro\>"
syn match nsisMacro			"^\s*\zs!macro\>"
syn match nsisMacro			"^\s*\zs!macroend\>"
syn match nsisDefine		"^\s*\zs!searchparse\>"
syn match nsisDefine		"^\s*\zs!searchreplace\>"
syn match nsisAttribOptions	'\/ignorecase'
syn match nsisAttribOptions	'\/noerrors'
syn match nsisAttribOptions	'\/file'


"Pages: (4.5)
syn keyword nsisStatement	Page UninstPage PageEx PageExEnd PageCallbacks


"Sections: (4.6)
syn keyword	nsisStatement		AddSize Section SectionEnd SectionIn SectionGroup SectionGroupEnd
syn match	nsisAttribOptions	'\/o'
syn keyword	nsisAttribOptions	RO


"Functions: (4.7)

"Functions Commands: (4.7.1)
syn keyword nsisStatement	Function FunctionEnd

"Callback Functions: (4.7.2)
syn match nsisCallback		"\.onGUIInit"
syn match nsisCallback		"\.onInit"
syn match nsisCallback		"\.onInstFailed"
syn match nsisCallback		"\.onInstSuccess"
syn match nsisCallback		"\.onGUIEnd"
syn match nsisCallback		"\.onMouseOverSelection"
syn match nsisCallback		"\.onRebootFailed"
syn match nsisCallback		"\.onSelChange"
syn match nsisCallback		"\.onUserAbort"
syn match nsisCallback		"\.onVerifyInstDir"
syn match nsisCallback		"un\.onGUIInit"
syn match nsisCallback		"un\.onInit"
syn match nsisCallback		"un\.onUninstFailed"
syn match nsisCallback		"un\.onUninstSuccess"
syn match nsisCallback		"un\.onGUIEnd"
syn match nsisCallback		"un\.onRebootFailed"
syn match nsisCallback		"un\.onSelChange"
syn match nsisCallback		"un\.onUserAbort"


"Installer Attributes: (4.8)
syn keyword nsisAttribute	AddBrandingImage AllowRootDirInstall AutoCloseWindow BGFont BGGradient BrandingText Caption ChangeUI CheckBitmap CompletedText ComponentText CRCCheck DetailsButtonText DirText DirVar DirVerify FileErrorText Icon InstallButtonText InstallColors InstallDir InstallDirRegKey InstProgressFlags InstType LicenseBkColor LicenseData LicenseForceSelection LicenseText MiscButtonText Name OutFile RequestExecutionLevel SetFont ShowInstDetails ShowUninstDetails SilentInstall SilentUnInstall SpaceTexts SubCaption UninstallButtonText UninstallCaption UninstallIcon UninstallSubCaption UninstallText WindowIcon XPStyle
syn keyword nsisCompiler	AllowSkipFiles FileBufSize SetCompress SetCompressor SetCompressorDictSize SetDatablockOptimize SetDateSave SetOverwrite
syn keyword nsisVersionInfo VIAddVersionKey VIProductVersion


"Instructions: (4.9)

"Various Arguments For Instructions: (4.9.*)
syn keyword nsisAttribOptions	left right top bottom true false on off force auto leave checkbox radiobuttons none user highest admin hide show nevershow normal silent silentlog
syn keyword nsisAttribOptions	zlib bzip2 lzma try ifnewer ifdiff 32 64 lastused
syn keyword nsisAttribOptions	smooth colored SET CUR END none listonly textonly both current all

syn match nsisAttribOptions	'\/TRIM\(LEFT\|RIGHT\|CENTER\)'
syn match nsisAttribOptions	'\/windows'
syn match nsisAttribOptions	'\/NOCUSTOM'
syn match nsisAttribOptions	'\/CUSTOMSTRING='
syn match nsisAttribOptions	'\/COMPONENTSONLYONCUSTOM'
syn match nsisAttribOptions	'\/gray'
syn match nsisAttribOptions	'\/LANG='
syn match nsisAttribOptions	'\/SOLID'
syn match nsisAttribOptions	'\/FINAL'

syn match nsisAttribOptions	'\/GLOBAL'

syn match nsisAttribOptions	'\/REBOOTOK'
syn match nsisAttribOptions	'\/nonfatal'
syn match nsisAttribOptions	'\/a'
syn match nsisAttribOptions	'\/r'
syn match nsisAttribOptions	'\/x'
syn match nsisAttribOptions	'\/oname='
syn match nsisAttribOptions	'\/SILENT'
syn match nsisAttribOptions	'\/FILESONLY'
syn match nsisAttribOptions	'\/ifempty'
syn match nsisAttribOptions	'\/SHORT'
syn match nsisAttribOptions	'\/SD'

syn match nsisAttribOptions	'\/IMGID='
syn match nsisAttribOptions	'\/RESIZETOFIT'
syn match nsisAttribOptions	'\/BRANDING'

syn keyword nsisExecShell	SW_SHOWNORMAL SW_SHOWMAXIMIZED SW_SHOWMINIMIZED SW_HIDE

syn keyword nsisRegistry	HKCR HKLM HKCU HKU HKCC HKDD HKPD SHCTX HKEY_CLASSES_ROOT HKEY_LOCAL_MACHINE HKEY_CURRENT_USER HKEY_USERS HKEY_CURRENT_CONFIG HKEY_DYN_DATA HKEY_PERFORMANCE_DATA SHELL_CONTEXT

syn keyword nsisFileAttrib	NORMAL ARCHIVE HIDDEN OFFLINE READONLY SYSTEM TEMPORARY FILE_ATTRIBUTE_NORMAL FILE_ATTRIBUTE_ARCHIVE FILE_ATTRIBUTE_HIDDEN FILE_ATTRIBUTE_OFFLINE FILE_ATTRIBUTE_READONLY FILE_ATTRIBUTE_SYSTEM FILE_ATTRIBUTE_TEMPORARY

syn keyword nsisMessageBox	MB_OK MB_OKCANCEL MB_ABORTRETRYIGNORE MB_RETRYCANCEL MB_YESNO MB_YESNOCANCEL MB_ICONEXCLAMATION MB_ICONINFORMATION MB_ICONQUESTION MB_ICONSTOP MB_TOPMOST MB_SETFOREGROUND MB_RIGHT MB_DEFBUTTON1 MB_DEFBUTTON2 MB_DEFBUTTON3 MB_DEFBUTTON4 IDABORT IDCANCEL IDIGNORE IDNO IDOK IDRETRY IDYES


"Basic Instructions: (4.9.1)
syn keyword nsisInstruction	Delete Exec ExecShell ExecWait File Rename ReserveFile RMDir SetOutPath

"Registry And INI And File Instructions: (4.9.2)
syn keyword nsisInstruction	DeleteINISec DeleteINIStr DeleteRegKey DeleteRegValue EnumRegKey EnumRegValue ExpandEnvStrings FlushINI ReadEnvStr ReadINIStr ReadRegDWORD ReadRegStr WriteINIStr WriteRegBin WriteRegDWORD WriteRegStr WriteRegExpandStr

"General Purpose Instructions: (4.9.3)
syn keyword nsisInstruction	CallInstDLL CopyFiles CreateDirectory CreateShortCut GetDLLVersion GetDLLVersionLocal GetFileTime GetFileTimeLocal GetFullPathName GetTempFileName SearchPath SetFileAttributes RegDLL UnRegDLL

"Flow Control Instructions: (4.9.4)
syn keyword nsisInstruction	Abort Call ClearErrors GetCurrentAddress GetFunctionAddress GetLabelAddress Goto IfAbort IfErrors IfFileExists IfRebootFlag IfSilent IntCmp IntCmpU MessageBox Return Quit SetErrors StrCmp StrCmpS

"File Instructions: (4.9.5)
syn keyword nsisInstruction	FindClose FileOpen FileRead FileReadByte FileSeek FileWrite FileWriteByte FileClose FindFirst FindNext

"Uninstaller Instructions: (4.9.6)
syn keyword nsisInstruction WriteUninstaller

"Miscellaneous Instructions: (4.9.7)
syn keyword nsisInstruction	GetErrorLevel GetInstDirError InitPluginsDir Nop SetErrorLevel SetRegView SetShellVarContext Sleep

"String Manipulation Instructions: (4.9.8)
syn keyword nsisInstruction StrCpy StrLen

"Stack Support: (4.9.9)
syn keyword nsisInstruction Exch Pop Push

"Integer Support: (4.9.10)
syn keyword nsisInstruction IntFmt IntOp

"Reboot Instructions: (4.9.11)
syn keyword nsisInstruction Reboot SetRebootFlag

"Install Logging Instructions: (4.9.12)
syn keyword nsisInstruction LogSet LogText

"Section Management: (4.9.13)
syn keyword nsisInstruction SectionSetFlags SectionGetFlags SectionSetText SectionGetText SectionSetInstTypes SectionGetInstTypes SectionSetSize SectionGetSize SetCurInstType GetCurInstType InstTypeSetText InstTypeGetText

"User Interface Instructions: (4.9.14)
syn keyword nsisInstruction BringToFront CreateFont DetailPrint EnableWindow FindWindow GetDlgItem HideWindow IsWindow LockWindow SendMessage SetAutoClose SetBrandingImage SetDetailsView SetDetailsPrint SetCtlColors SetSilent ShowWindow

"Multiple Languages Instructions: (4.9.15)
syn keyword nsisInstruction LoadLanguageFile LangString LicenseLangString
syn match nsisLangSubst "$(.\{-})"


"Other Additions:

"LogicLib Definitions:
syn keyword nsisLogicLibKeyword	contained \| \|\| Abort Errors FileExists RebootFlag Silent Cmd SectionIsSelected SectionIsSubSection SectionIsSubSectionEnd SectionIsSectionGroup SectionIsSectionGroupEnd SectionIsBold SectionIsReadOnly SectionIsExpanded SectionIsPartiallySelected IfCmd If Unless IfNot AndIf AndUnless AndIfNot OrIf OrUnless OrIfNot Else ElseIf ElseUnless ElseIfNot EndIf EndUnless IfThen IfNotThen ForEach For ExitFor Next While ExitWhile EndWhile Do DoWhile DoUntil ExitDo Loop LoopWhile LoopUntil Continue Break Select CaseElse Case_Else Default Case Case2 Case3 Case4 Case5 EndSelect Switch EndSwitch


" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_nsis_syn_inits")

  if version < 508
    let did_nsys_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif


  HiLink nsisLogicLibKeyword	Conditional
  HiLink nsisInstruction		Function
  HiLink nsisComment			Comment
  HiLink nsisLocalLabel			Label
  HiLink nsisGlobalLabel		Label
  HiLink nsisPluginCall 		Special
  HiLink nsisStatement			Statement
  HiLink nsisString				String
  HiLink nsisAttribOptions		Constant
  HiLink nsisExecShell			Constant
  HiLink nsisFileAttrib			Constant
  HiLink nsisMessageBox			Constant
  HiLink nsisRegistry			Identifier
  HiLink nsisNumber				Number
  HiLink nsisError				Error
  HiLink nsisVarCommand			Type
  HiLink nsisUserVar			Identifier
  HiLink nsisSysVar				Identifier
  HiLink nsisConstVar			Identifier
  HiLink nsisAttribute			Type
  HiLink nsisCompiler			Type
  HiLink nsisVersionInfo		Type
  HiLink nsisTodo				Todo
  HiLink nsisCallback			Operator
  " preprocessor commands
  HiLink nsisPreprocSubst		PreProc
  HiLink nsisLangSubst			PreProc
  HiLink nsisDefine				Define
  HiLink nsisMacro				Macro
  HiLink nsisPreCondit			PreCondit
  HiLink nsisInclude			Include
  HiLink nsisSystem				PreProc

  delcommand HiLink
endif

let b:current_syntax = "nsis"

