" Vim syntax file

" Language:	AutoIt from www.autoitscript.com
" Maintainer:	Riccardo Casini <ric@libero.it>
" ChangeLog:
" 		v1.5 01/08/07 by Jared Breland <jbreland@legroom.net>
" 			updated for AutoIt 3.2.2.0
" 			more cleanup for inclusion in Vim distribution
" 		v1.4 08/27/06 by Jared Breland <jbreland@legroom.net>
" 			update for AutoIt 3.2.0.1
" 			cleanup for inclusion in Vim distribution
" 		v1.3 05/13/06 by Jared Breland <jbreland@legroom.net>
" 			update for AutoIt 3.1.1.123-beta
" 			added Styles section
" 			added Constants section
" 			added Send Key section
" 			changed variable formatting to match PHP style
" 			(to better distinguish between user vars and built-ins)
"		v1.2 10/07/05 by Jared Breland <jbreland@legroom.net>
" 			update for AutoIt 3.1.1.78-beta
" 			added Options section
" 		v1.1 03/15/05 by Jared Breland <jbreland@legroom.net>
" 			updated for AutoIt 3.1.0

" used inside floating points
setl iskeyword+=.
setl iskeyword+=+

" Force definition of command HiLink, to assimilate from_group to to_group
" highlighting, only when an item doesn't have highlighting yet
"com! -nargs=+ HiLink hi def link <args>

" AutoIt is not case dependent
syn case ignore

" Definitions for AutoIt reserved keywords
syn keyword au3keyword Default False True
syn keyword au3Keyword Const Dim Global Local ReDim
syn keyword au3Keyword If Else ElseIf Then EndIf
syn keyword au3Keyword Select Switch Case EndSelect EndSwitch
syn keyword au3Keyword Enum For In To Step Next
syn keyword au3Keyword With While EndWith Wend
syn keyword au3Keyword Do Until
syn keyword au3Keyword ContinueCase ContinueLoop ExitLoop Exit

" inside script inclusion and global options
syn match au3Included display contained "<[^>]*>"
syn match au3Include	display "^\s*#\s*include\>\s*["<]"
	\ contains=au3Included,au3String
syn match au3Include "^\s*#include-once\>"
syn match au3Include "^\s*#NoTrayIcon\>"
syn match au3Include "^\s*#RequireAdmin\>"

" user-defined functions
syn keyword au3Keyword Func ByRef EndFunc Return OnAutoItStart OnAutoItExit

" built-in functions
" environment management
syn keyword au3Function ClipGet ClipPut EnvGet EnvSet EnvUpdate MemGetStats
" file, directory, and disk management
syn keyword au3Function ConsoleRead ConsoleWrite ConsoleWriteError
syn keyword au3Function DirCopy DirCreate DirGetSize DirMove DirRemove
syn keyword au3Function DriveGetDrive DriveGetFileSystem DriveGetLabel
	\ DriveGetSerial DriveGetType DriveMapAdd DriveMapDel DriveMapGet
	\ DriveSetLabel DriveSpaceFree DriveSpaceTotal DriveStatus
syn keyword au3Function FileChangeDir FileClose FileCopy FileCreateNTFSLink
	\ FileCreateShortcut FileDelete FileExists FileFindFirstFile
	\ FileFindNextFile FileGetAttrib FileGetLongName FileGetShortcut
	\ FileGetShortName FileGetSize FileGetTime FileGetVersion FileInstall
	\ FileMove FileOpen FileOpenDialog FileRead FileReadLine FileRecycle
	\ FileRecycleEmpty FileSaveDialog FileSelectFolder FileSetAttrib
	\ FileSetTime FileWrite FileWriteLine
syn keyword au3Function IniDelete IniRead IniReadSection IniReadSectionNames
	\ IniRenameSection IniWrite IniWriteSection
syn keyword au3Function StderrRead StdinWrite StdoutRead
" graphic and sound
syn keyword au3Function Beep PixelChecksum PixelGetColor PixelSearch SoundPlay
	\ SoundSetWaveVolume
" gui reference
syn keyword au3Function GUICreate GUIDelete GUICtrlGetHandle GUICtrlGetState
	\ GUICtrlRead GUICtrlRecvMsg GUICtrlSendMsg GUICtrlSendToDummy
	\ GUIGetCursorInfo GUIGetMsg GUIRegisterMsg GUIStartGroup GUISwitch
syn keyword au3Function GUICtrlCreateAvi GUICtrlCreateButton
	\ GUICtrlCreateCheckbox GUICtrlCreateCombo GUICtrlCreateContextMenu
	\ GUICtrlCreateDate GUICtrlCreateDummy GUICtrlCreateEdit
	\ GUICtrlCreateGraphic GUICtrlCreateGroup GUICtrlCreateIcon
	\ GUICtrlCreateInput GUICtrlCreateLabel GUICtrlCreateList
	\ GUICtrlCreateListView GUICtrlCreateListViewItem GUICtrlCreateMenu
	\ GUICtrlCreateMenuItem GUICtrlCreateMonthCal GUICtrlCreateObj
	\ GUICtrlCreatePic GUICtrlCreateProgress GUICtrlCreateRadio
	\ GUICtrlCreateSlider GUICtrlCreateTab GUICtrlCreateTabItem
	\ GUICtrlCreateTreeView GUICtrlCreateTreeViewItem
	\ GUICtrlCreateUpDown GUICtrlDelete
syn keyword au3Function GUICtrlRegisterListViewSort GUICtrlSetBkColor
	\ GUICtrlSetColor GUICtrlSetCursor GUICtrlSetData GUICtrlSetFont
	\ GUICtrlSetGraphic GUICtrlSetImage GUICtrlSetLimit GUICtrlSetOnEvent
	\ GUICtrlSetPos GUICtrlSetResizing GUICtrlSetState GUICtrlSetStyle
	\ GUICtrlSetTip
syn keyword au3Function GUISetBkColor GUISetCoord GUISetCursor GUISetFont
	\ GUISetHelp GUISetIcon GUISetOnEvent GUISetState
" keyboard control
syn keyword au3Function HotKeySet Send
" math
syn keyword au3Function Abs ACos ASin ATan BitAND BitNOT BitOR BitRotate BitShift
	\ BitXOR Cos Ceiling Exp Floor Log Mod Random Round Sin Sqrt SRandom Tan
" message boxes and dialogs
syn keyword au3Function InputBox MsgBox ProgressOff ProgressOn ProgressSet
	\ SplashImageOn SplashOff SplashTextOn ToolTip
" miscellaneous
syn keyword au3Function AdlibDisable AdlibEnable AutoItSetOption
	\ AutoItWinGetTitle AutoItWinSetTitle BlockInput Break Call CDTray
	\ Execute Opt SetError SetExtended
" mouse control
syn keyword au3Function MouseClick MouseClickDrag MouseDown MouseGetCursor
	\ MouseGetPos MouseMove MouseUp MouseWheel
" network
syn keyword au3Function FtpSetProxy HttpSetProxy InetGet InetGetSize Ping
	\ TCPAccept TCPCloseSocket TCPConnect TCPListen TCPNameToIp TCPRecv
	\ TCPSend TCPShutDown TCPStartup UDPBind UDPCloseSocket UDPOpen UDPRecv
	\ UDPSend UDPShutdown UDPStartup
" obj/com reference
syn keyword au3Function ObjCreate ObjEvent ObjGet ObjName
" process management
syn keyword au3Function DllCall DllClose DllOpen DllStructCreate DllStructGetData
	\ DllStructGetPtr DllStructGetSize DllStructSetData ProcessClose
	\ ProcessExists ProcessSetPriority ProcessList ProcessWait
	\ ProcessWaitClose Run RunAsSet RunWait ShellExecute ShellExecuteWait
	\ Shutdown
	" removed from 3.2.0 docs - PluginClose PluginOpen
" registry management
syn keyword au3Function RegDelete RegEnumKey RegEnumVal RegRead RegWrite
" string management
syn keyword au3Function StringAddCR StringFormat StringInStr StringIsAlNum
	\ StringIsAlpha StringIsASCII StringIsDigit StringIsFloat StringIsInt
	\ StringIsLower StringIsSpace StringIsUpper StringIsXDigit StringLeft
	\ StringLen StringLower StringMid StringRegExp StringRegExpReplace
	\ StringReplace StringRight StringSplit StringStripCR StringStripWS
	\ StringTrimLeft StringTrimRight StringUpper
" timer and delay
syn keyword au3Function Sleep TimerInit TimerDiff
" tray
syn keyword au3Function TrayCreateItem TrayCreateMenu TrayItemDelete
	\ TrayItemGetHandle TrayItemGetState TrayItemGetText TrayItemSetOnEvent
	\ TrayItemSetState TrayItemSetText TrayGetMsg TraySetClick TraySetIcon
	\ TraySetOnEvent TraySetPauseIcon TraySetState TraySetToolTip TrayTip
" variables and conversions
syn keyword au3Function Asc Assign Binary Chr Dec Eval Hex HWnd Int IsAdmin
	\ IsArray IsBinaryString IsBool IsDeclared IsDllStruct IsFloat IsHWnd IsInt
	\ IsKeyword IsNumber IsObj IsString Number String UBound
" window management
syn keyword au3Function WinActivate WinActive WinClose WinExists WinFlash
	\ WinGetCaretPos WinGetClassList WinGetClientSize WinGetHandle WinGetPos
	\ WinGetProcess WinGetState WinGetText WinGetTitle WinKill WinList
	\ WinMenuSelectItem WinMinimizeAll WinMinimizeAllUndo WinMove
	\ WinSetOnTop WinSetState WinSetTitle WinSetTrans WinWait WinWaitActive
	\ WinWaitClose WinWaitNotActive
syn keyword au3Function ControlClick ControlCommand ControlDisable ControlEnable
	\ ControlFocus ControlGetFocus ControlGetHandle ControlGetPos
	\ ControlGetText ControlHide ControlListView ControlMove ControlSend
	\ ControlSetText ControlShow StatusBarGetText

" user defined functions
" array
syn keyword au3Function _ArrayAdd _ArrayBinarySearch _ArrayCreate _ArrayDelete
	\ _ArrayDisplay _ArrayInsert _ArrayMax _ArrayMaxIndex _ArrayMin
	\ _ArrayMinIndex _ArrayPop _ArrayPush _ArrayReverse _ArraySearch
	\ _ArraySort _ArraySwap _ArrayToClip _ArrayToString _ArrayTrim
" color
syn keyword au3Function _ColorgetBlue _ColorGetGreen _ColorGetRed
" date
syn keyword au3Function _DateAdd _DateDayOfWeek _DateDaysInMonth _DateDiff
	\ _DateIsLeapYear _DateIsValid _DateTimeFormat _DateTimeSplit
	\ _DateToDayOfWeek _ToDayOfWeekISO _DateToDayValue _DayValueToDate _Now
	\ _NowCalc _NowCalcDate _NowDate _NowTime _SetDate _SetTime _TicksToTime
	\ _TimeToTicks _WeekNumberISO
" file
syn keyword au3Function _FileCountLines _FileCreate _FileListToArray _FilePrint
	\ _FileReadToArray _FileWriteFromArray _FileWriteLog _FileWriteToLine
	\ _PathFull _PathMake _PathSplit _ReplaceStringInFile _TempFile
" guicombo
syn keyword au3Function _GUICtrlComboAddDir _GUICtrlComboAddString
	\ _GUICtrlComboAutoComplete _GUICtrlComboDeleteString
	\ _GUICtrlComboFindString _GUICtrlComboGetCount _GUICtrlComboGetCurSel
	\ _GUICtrlComboGetDroppedControlRect _GUICtrlComboGetDroppedState
	\ _GUICtrlComboGetDroppedWidth _GUICtrlComboGetEditSel
	\ _GUICtrlComboGetExtendedUI _GUICtrlComboGetHorizontalExtent
	\ _GUICtrlComboGetItemHeight _GUICtrlComboGetLBText
	\ _GUICtrlComboGetLBTextLen _GUICtrlComboGetList _GUICtrlComboGetLocale
	\ _GUICtrlComboGetMinVisible _GUICtrlComboGetTopIndex
	\ _GUICtrlComboInitStorage _GUICtrlComboInsertString
	\ _GUICtrlComboLimitText _GUICtrlComboResetContent
	\ _GUICtrlComboSelectString _GUICtrlComboSetCurSel
	\ _GUICtrlComboSetDroppedWidth _GUICtrlComboSetEditSel
	\ _GUICtrlComboSetExtendedUI _GUICtrlComboSetHorizontalExtent
	\ _GUICtrlComboSetItemHeight _GUICtrlComboSetMinVisible
	\ _GUICtrlComboSetTopIndex _GUICtrlComboShowDropDown
" guiedit
syn keyword au3Function _GUICtrlEditCanUndo _GUICtrlEditEmptyUndoBuffer
	\ _GuiCtrlEditFind _GUICtrlEditGetFirstVisibleLine _GUICtrlEditGetLine
	\ _GUICtrlEditGetLineCount _GUICtrlEditGetModify _GUICtrlEditGetRect
	\ _GUICtrlEditGetSel _GUICtrlEditLineFromChar _GUICtrlEditLineIndex
	\ _GUICtrlEditLineLength _GUICtrlEditLineScroll _GUICtrlEditReplaceSel
	\ _GUICtrlEditScroll _GUICtrlEditSetModify _GUICtrlEditSetRect
	\ _GUICtrlEditSetSel _GUICtrlEditUndo
" guiipaddress
syn keyword au3Function _GUICtrlIpAddressClear _GUICtrlIpAddressCreate
	\ _GUICtrlIpAddressDelete _GUICtrlIpAddressGet _GUICtrlIpAddressIsBlank
	\ _GUICtrlIpAddressSet _GUICtrlIpAddressSetFocus _GUICtrlIpAddressSetFont
	\ _GUICtrlIpAddressSetRange _GUICtrlIpAddressShowHide
" guilist
syn keyword au3Function _GUICtrlListAddDir _GUICtrlListAddItem _GUICtrlListClear
	\ _GUICtrlListCount _GUICtrlListDeleteItem _GUICtrlListFindString
	\ _GUICtrlListGetAnchorIndex _GUICtrlListGetCaretIndex
	\ _GUICtrlListGetHorizontalExtent _GUICtrlListGetInfo
	\ _GUICtrlListGetItemRect _GUICtrlListGetLocale _GUICtrlListGetSelCount
	\ _GUICtrlListGetSelItems _GUICtrlListGetSelItemsText
	\ _GUICtrlListGetSelState _GUICtrlListGetText _GUICtrlListGetTextLen
	\ _GUICtrlListGetTopIndex _GUICtrlListInsertItem
	\ _GUICtrlListReplaceString _GUICtrlListSelectedIndex
	\ _GUICtrlListSelectIndex _GUICtrlListSelectString
	\ _GUICtrlListSelItemRange _GUICtrlListSelItemRangeEx
	\ _GUICtrlListSetAnchorIndex _GUICtrlListSetCaretIndex
	\ _GUICtrlListSetHorizontalExtent _GUICtrlListSetLocale
	\ _GUICtrlListSetSel _GUICtrlListSetTopIndex _GUICtrlListSort
	\ _GUICtrlListSwapString
" guilistview
syn keyword au3Function _GUICtrlListViewCopyItems _GUICtrlListViewDeleteAllItems
	\ _GUICtrlListViewDeleteColumn _GUICtrlListViewDeleteItem
	\ _GUICtrlListViewDeleteItemsSelected _GUICtrlListViewEnsureVisible
	\ _GUICtrlListViewFindItem _GUICtrlListViewGetBackColor
	\ _GUICtrlListViewGetCallBackMask _GUICtrlListViewGetCheckedState
	\ _GUICtrlListViewGetColumnOrder _GUICtrlListViewGetColumnWidth
	\ _GUICtrlListViewGetCounterPage _GUICtrlListViewGetCurSel
	\ _GUICtrlListViewGetExtendedListViewStyle _GUICtrlListViewGetHeader
	\ _GUICtrlListViewGetHotCursor _GUICtrlListViewGetHotItem
	\ _GUICtrlListViewGetHoverTime _GUICtrlListViewGetItemCount
	\ _GUICtrlListViewGetItemText _GUICtrlListViewGetItemTextArray
	\ _GUICtrlListViewGetNextItem _GUICtrlListViewGetSelectedCount
	\ _GUICtrlListViewGetSelectedIndices _GUICtrlListViewGetSubItemsCount
	\ _GUICtrlListViewGetTopIndex _GUICtrlListViewGetUnicodeFormat
	\ _GUICtrlListViewHideColumn _GUICtrlListViewInsertColumn
	\ _GUICtrlListViewInsertItem _GUICtrlListViewJustifyColumn
	\ _GUICtrlListViewScroll _GUICtrlListViewSetCheckState
	\ _GUICtrlListViewSetColumnHeaderText _GUICtrlListViewSetColumnOrder
	\ _GUICtrlListViewSetColumnWidth _GUICtrlListViewSetHotItem
	\ _GUICtrlListViewSetHoverTime _GUICtrlListViewSetItemCount
	\ _GUICtrlListViewSetItemSelState _GUICtrlListViewSetItemText
	\ _GUICtrlListViewSort
" guimonthcal
syn keyword au3Function _GUICtrlMonthCalGet1stDOW _GUICtrlMonthCalGetColor
	\ _GUICtrlMonthCalGetDelta _GUICtrlMonthCalGetMaxSelCount
	\ _GUICtrlMonthCalGetMaxTodayWidth _GUICtrlMonthCalGetMinReqRect
	\ _GUICtrlMonthCalSet1stDOW _GUICtrlMonthCalSetColor
	\ _GUICtrlMonthCalSetDelta _GUICtrlMonthCalSetMaxSelCount
" guislider
syn keyword au3Function _GUICtrlSliderClearTics _GUICtrlSliderGetLineSize
	\ _GUICtrlSliderGetNumTics _GUICtrlSliderGetPageSize
	\ _GUICtrlSliderGetPos _GUICtrlSliderGetRangeMax
	\ _GUICtrlSliderGetRangeMin _GUICtrlSliderSetLineSize
	\ _GUICtrlSliderSetPageSize _GUICtrlSliderSetPos
	\ _GUICtrlSliderSetTicFreq
" guistatusbar
syn keyword au3Function _GuiCtrlStatusBarCreate _GUICtrlStatusBarCreateProgress
	\ _GUICtrlStatusBarDelete _GuiCtrlStatusBarGetBorders
	\ _GuiCtrlStatusBarGetIcon _GuiCtrlStatusBarGetParts
	\ _GuiCtrlStatusBarGetRect _GuiCtrlStatusBarGetText
	\ _GuiCtrlStatusBarGetTextLength _GuiCtrlStatusBarGetTip
	\ _GuiCtrlStatusBarGetUnicode _GUICtrlStatusBarIsSimple 
	\ _GuiCtrlStatusBarResize _GuiCtrlStatusBarSetBKColor
	\ _GuiCtrlStatusBarSetIcon _GuiCtrlStatusBarSetMinHeight
	\ _GUICtrlStatusBarSetParts _GuiCtrlStatusBarSetSimple
	\ _GuiCtrlStatusBarSetText _GuiCtrlStatusBarSetTip
	\ _GuiCtrlStatusBarSetUnicode _GUICtrlStatusBarShowHide 
" guitab
syn keyword au3Function _GUICtrlTabDeleteAllItems _GUICtrlTabDeleteItem
	\ _GUICtrlTabDeselectAll _GUICtrlTabGetCurFocus _GUICtrlTabGetCurSel
	\ _GUICtrlTabGetExtendedStyle _GUICtrlTabGetItemCount
	\ _GUICtrlTabGetItemRect _GUICtrlTabGetRowCount
	\ _GUICtrlTabGetUnicodeFormat _GUICtrlTabHighlightItem
	\ _GUICtrlTabSetCurFocus _GUICtrlTabSetCurSel
	\ _GUICtrlTabSetMinTabWidth _GUICtrlTabSetUnicodeFormat
" guitreeview
syn keyword au3Function _GUICtrlTreeViewDeleteAllItems
	\ _GUICtrlTreeViewDeleteItem _GUICtrlTreeViewExpand
	\ _GUICtrlTreeViewGetBkColor _GUICtrlTreeViewGetCount
	\ _GUICtrlTreeViewGetIndent _GUICtrlTreeViewGetLineColor
	\ _GUICtrlTreeViewGetParentHandle _GUICtrlTreeViewGetParentID
	\ _GUICtrlTreeViewGetState _GUICtrlTreeViewGetText
	\ _GUICtrlTreeViewGetTextColor _GUICtrlTreeViewItemGetTree
	\ _GUICtrlTreeViewInsertItem _GUICtrlTreeViewSetBkColor
	\ _GUICtrlTreeViewSetIcon _GUICtrlTreeViewSetIndent
	\ _GUICtrlTreeViewSetLineColor GUICtrlTreeViewSetState
	\ _GUICtrlTreeViewSetText _GUICtrlTreeViewSetTextColor _GUICtrlTreeViewSort
" ie
syn keyword au3Function _IE_Example _IE_Introduction _IE_VersionInfo _IEAction
	\ _IEAttach _IEBodyReadHTML _IEBodyReadText _IEBodyWriteHTML _IECreate
	\ _IECreateEmbedded _IEDocGetObj _IEDocInsertHTML _IEDocInsertText
	\ _IEDocReadHTML _IEDocWriteHTML _IEErrorHandlerDeRegister
	\ _IEErrorHandlerRegister _IEErrorNotify _IEFormElementCheckboxSelect
	\ _IEFormElementGetCollection _IEFormElementGetObjByName
	\ _IEFormElementGetValue _IEFormElementOptionSelect
	\ _IEFormElementRadioSelect _IEFormElementSetValue _IEFormGetCollection
	\ _IEFormGetObjByName _IEFormImageClick _IEFormReset _IEFormSubmit
	\ _IEFrameGetCollection _IEFrameGetObjByName _IEGetObjByName
	\ _IEHeadInsertEventScript _IEImgClick _IEImgGetCollection _IEIsFrameSet
	\ _IELinkClickByIndex _IELinkClickByText _IELinkGetCollection _IELoadWait
	\ _IELoadWaitTimeout _IENavigate _IEPropertyGet _IEPropertySet _IEQuit
	\ _IETableGetCollection _IETableWriteToArray _IETagNameAllGetCollection
	\ _IETagNameGetCollection
" inet
syn keyword au3Function _GetIP _INetExplorerCapable _INetGetSource _INetMail
	\ _INetSmtpMail _TCPIpToName
" math
syn keyword au3Function _Degree _MathCheckDiv _Max _Min _Radian
" miscellaneous
syn keyword au3Function _ChooseColor _ChooseFont _ClipPutFile _Iif _IsPressed
	\ _MouseTrap _SendMessage _Singleton
" process
syn keyword au3Function _ProcessGetName _ProcessGetPriority _RunDOS
" sound
syn keyword au3Function _SoundClose _SoundLength _SoundOpen _SoundPause
	\ _SoundPlay _SoundPos _SoundResume _SoundSeek _SoundStatus _SoundStop
" sqlite
syn keyword au3Function _SQLite_Changes _SQLite_Close _SQLite_Display2DResult
	\ _SQLite_Encode _SQLite_ErrCode _SQLite_ErrMsg _SQLite_Escape _SQLite_Exec
	\ _SQLite_FetchData _SQLite_FetchNames _SQLite_GetTable _SQLite_GetTable2D
	\ _SQLite_LastInsertRowID _SQLite_LibVersion _SQLite_Open _SQLite_Query
	\ _SQLite_QueryFinalize _SQLite_QueryReset _SQLite_QuerySingleRow
	\ _SQLite_SaveMode _SQLite_SetTimeout _SQLite_Shutdown _SQLite_SQLiteExe
	\ _SQLite_Startup _SQLite_TotalChanges
" string
syn keyword au3Function _HexToString _StringAddComma _StringBetween
	\ _StringEncrypt _StringInsert _StringProper _StringRepeat _StringReverse
	\ _StringToHex
" visa
syn keyword au3Function _viClose _viExecCommand _viFindGpib _viGpibBusReset
	\ _viGTL _viOpen _viSetAttribute _viSetTimeout

" read-only macros
syn match au3Builtin "@AppData\(Common\)\=Dir"
syn match au3Builtin "@AutoItExe"
syn match au3Builtin "@AutoItPID"
syn match au3Builtin "@AutoItVersion"
syn match au3Builtin "@COM_EventObj"
syn match au3Builtin "@CommonFilesDir"
syn match au3Builtin "@Compiled"
syn match au3Builtin "@ComputerName"
syn match au3Builtin "@ComSpec"
syn match au3Builtin "@CR\(LF\)\="
syn match au3Builtin "@Desktop\(Common\)\=Dir"
syn match au3Builtin "@DesktopDepth"
syn match au3Builtin "@DesktopHeight"
syn match au3Builtin "@DesktopRefresh"
syn match au3Builtin "@DesktopWidth"
syn match au3Builtin "@DocumentsCommonDir"
syn match au3Builtin "@Error"
syn match au3Builtin "@ExitCode"
syn match au3Builtin "@ExitMethod"
syn match au3Builtin "@Extended"
syn match au3Builtin "@Favorites\(Common\)\=Dir"
syn match au3Builtin "@GUI_CtrlId"
syn match au3Builtin "@GUI_CtrlHandle"
syn match au3Builtin "@GUI_DragId"
syn match au3Builtin "@GUI_DragFile"
syn match au3Builtin "@GUI_DropId"
syn match au3Builtin "@GUI_WinHandle"
syn match au3Builtin "@HomeDrive"
syn match au3Builtin "@HomePath"
syn match au3Builtin "@HomeShare"
syn match au3Builtin "@HOUR"
syn match au3Builtin "@HotKeyPressed"
syn match au3Builtin "@InetGetActive"
syn match au3Builtin "@InetGetBytesRead"
syn match au3Builtin "@IPAddress[1234]"
syn match au3Builtin "@KBLayout"
syn match au3Builtin "@LF"
syn match au3Builtin "@Logon\(DNS\)\=Domain"
syn match au3Builtin "@LogonServer"
syn match au3Builtin "@MDAY"
syn match au3Builtin "@MIN"
syn match au3Builtin "@MON"
syn match au3Builtin "@MyDocumentsDir"
syn match au3Builtin "@NumParams"
syn match au3Builtin "@OSBuild"
syn match au3Builtin "@OSLang"
syn match au3Builtin "@OSServicePack"
syn match au3Builtin "@OSTYPE"
syn match au3Builtin "@OSVersion"
syn match au3Builtin "@ProcessorArch"
syn match au3Builtin "@ProgramFilesDir"
syn match au3Builtin "@Programs\(Common\)\=Dir"
syn match au3Builtin "@ScriptDir"
syn match au3Builtin "@ScriptFullPath"
syn match au3Builtin "@ScriptLineNumber"
syn match au3Builtin "@ScriptName"
syn match au3Builtin "@SEC"
syn match au3Builtin "@StartMenu\(Common\)\=Dir"
syn match au3Builtin "@Startup\(Common\)\=Dir"
syn match au3Builtin "@SW_DISABLE"
syn match au3Builtin "@SW_ENABLE"
syn match au3Builtin "@SW_HIDE"
syn match au3Builtin "@SW_LOCK"
syn match au3Builtin "@SW_MAXIMIZE"
syn match au3Builtin "@SW_MINIMIZE"
syn match au3Builtin "@SW_RESTORE"
syn match au3Builtin "@SW_SHOW"
syn match au3Builtin "@SW_SHOWDEFAULT"
syn match au3Builtin "@SW_SHOWMAXIMIZED"
syn match au3Builtin "@SW_SHOWMINIMIZED"
syn match au3Builtin "@SW_SHOWMINNOACTIVE"
syn match au3Builtin "@SW_SHOWNA"
syn match au3Builtin "@SW_SHOWNOACTIVATE"
syn match au3Builtin "@SW_SHOWNORMAL"
syn match au3Builtin "@SW_UNLOCK"
syn match au3Builtin "@SystemDir"
syn match au3Builtin "@TAB"
syn match au3Builtin "@TempDir"
syn match au3Builtin "@TRAY_ID"
syn match au3Builtin "@TrayIconFlashing"
syn match au3Builtin "@TrayIconVisible"
syn match au3Builtin "@UserProfileDir"
syn match au3Builtin "@UserName"
syn match au3Builtin "@WDAY"
syn match au3Builtin "@WindowsDir"
syn match au3Builtin "@WorkingDir"
syn match au3Builtin "@YDAY"
syn match au3Builtin "@YEAR"

"comments and commenting-out
syn match au3Comment ";.*"
"in this way also #ce alone will be highlighted
syn match au3CommDelimiter "^\s*#comments-start\>"
syn match au3CommDelimiter "^\s*#cs\>"
syn match au3CommDelimiter "^\s*#comments-end\>"
syn match au3CommDelimiter "^\s*#ce\>"
syn region au3Comment
	\ matchgroup=au3CommDelimiter
	\ start="^\s*#comments-start\>" start="^\s*#cs\>"
	\ end="^\s*#comments-end\>" end="^\s*#ce\>"

"one character operators
syn match au3Operator "[-+*/&^=<>][^-+*/&^=<>]"me=e-1
"two characters operators
syn match au3Operator "==[^=]"me=e-1
syn match au3Operator "<>"
syn match au3Operator "<="
syn match au3Operator ">="
syn match au3Operator "+="
syn match au3Operator "-="
syn match au3Operator "*="
syn match au3Operator "/="
syn match au3Operator "&="
syn keyword au3Operator NOT AND OR

syn match au3Paren "(\|)"
syn match au3Bracket "\[\|\]"
syn match au3Comma ","

"numbers must come after operator '-'
"decimal numbers without a dot
syn match au3Number "-\=\<\d\+\>"
"hexadecimal numbers without a dot
syn match au3Number "-\=\<0x\x\+\>"
"floating point number with dot (inside or at end)

syn match au3Number "-\=\<\d\+\.\d*\>"
"floating point number, starting with a dot
syn match au3Number "-\=\<\.\d\+\>"
"scientific notation numbers without dots
syn match au3Number "-\=\<\d\+e[-+]\=\d\+\>"
"scientific notation numbers with dots
syn match au3Number "-\=\<\(\(\d\+\.\d*\)\|\(\.\d\+\)\)\(e[-+]\=\d\+\)\=\>"

"string constants
"we want the escaped quotes marked in red
syn match au3DoubledSingles +''+ contained
syn match au3DoubledDoubles +""+ contained
"we want the continuation character marked in red
"(also at the top level, not just contained)
syn match au3Cont "_$"

" send key list - must be defined before au3Strings
syn match au3Send "{!}" contained
syn match au3Send "{#}" contained
syn match au3Send "{+}" contained
syn match au3Send "{^}" contained
syn match au3Send "{{}" contained
syn match au3Send "{}}" contained
syn match au3Send "{SPACE}" contained
syn match au3Send "{ENTER}" contained
syn match au3Send "{ALT}" contained
syn match au3Send "{BACKSPACE}" contained
syn match au3Send "{BS}" contained
syn match au3Send "{DELETE}" contained
syn match au3Send "{DEL}" contained
syn match au3Send "{UP}" contained
syn match au3Send "{DOWN}" contained
syn match au3Send "{LEFT}" contained
syn match au3Send "{RIGHT}" contained
syn match au3Send "{HOME}" contained
syn match au3Send "{END}" contained
syn match au3Send "{ESCAPE}" contained
syn match au3Send "{ESC}" contained
syn match au3Send "{INSERT}" contained
syn match au3Send "{INS}" contained
syn match au3Send "{PGUP}" contained
syn match au3Send "{PGDN}" contained
syn match au3Send "{F1}" contained
syn match au3Send "{F2}" contained
syn match au3Send "{F3}" contained
syn match au3Send "{F4}" contained
syn match au3Send "{F5}" contained
syn match au3Send "{F6}" contained
syn match au3Send "{F7}" contained
syn match au3Send "{F8}" contained
syn match au3Send "{F9}" contained
syn match au3Send "{F10}" contained
syn match au3Send "{F11}" contained
syn match au3Send "{F12}" contained
syn match au3Send "{TAB}" contained
syn match au3Send "{PRINTSCREEN}" contained
syn match au3Send "{LWIN}" contained
syn match au3Send "{RWIN}" contained
syn match au3Send "{NUMLOCK}" contained
syn match au3Send "{CTRLBREAK}" contained
syn match au3Send "{PAUSE}" contained
syn match au3Send "{CAPSLOCK}" contained
syn match au3Send "{NUMPAD0}" contained
syn match au3Send "{NUMPAD1}" contained
syn match au3Send "{NUMPAD2}" contained
syn match au3Send "{NUMPAD3}" contained
syn match au3Send "{NUMPAD4}" contained
syn match au3Send "{NUMPAD5}" contained
syn match au3Send "{NUMPAD6}" contained
syn match au3Send "{NUMPAD7}" contained
syn match au3Send "{NUMPAD8}" contained
syn match au3Send "{NUMPAD9}" contained
syn match au3Send "{NUMPADMULT}" contained
syn match au3Send "{NUMPADADD}" contained
syn match au3Send "{NUMPADSUB}" contained
syn match au3Send "{NUMPADDIV}" contained
syn match au3Send "{NUMPADDOT}" contained
syn match au3Send "{NUMPADENTER}" contained
syn match au3Send "{APPSKEY}" contained
syn match au3Send "{LALT}" contained
syn match au3Send "{RALT}" contained
syn match au3Send "{LCTRL}" contained
syn match au3Send "{RCTRL}" contained
syn match au3Send "{LSHIFT}" contained
syn match au3Send "{RSHIFT}" contained
syn match au3Send "{SLEEP}" contained
syn match au3Send "{ALTDOWN}" contained
syn match au3Send "{SHIFTDOWN}" contained
syn match au3Send "{CTRLDOWN}" contained
syn match au3Send "{LWINDOWN}" contained
syn match au3Send "{RWINDOWN}" contained
syn match au3Send "{ASC \d\d\d\d}" contained
syn match au3Send "{BROWSER_BACK}" contained
syn match au3Send "{BROWSER_FORWARD}" contained
syn match au3Send "{BROWSER_REFRESH}" contained
syn match au3Send "{BROWSER_STOP}" contained
syn match au3Send "{BROWSER_SEARCH}" contained
syn match au3Send "{BROWSER_FAVORITES}" contained
syn match au3Send "{BROWSER_HOME}" contained
syn match au3Send "{VOLUME_MUTE}" contained
syn match au3Send "{VOLUME_DOWN}" contained
syn match au3Send "{VOLUME_UP}" contained
syn match au3Send "{MEDIA_NEXT}" contained
syn match au3Send "{MEDIA_PREV}" contained
syn match au3Send "{MEDIA_STOP}" contained
syn match au3Send "{MEDIA_PLAY_PAUSE}" contained
syn match au3Send "{LAUNCH_MAIL}" contained
syn match au3Send "{LAUNCH_MEDIA}" contained
syn match au3Send "{LAUNCH_APP1}" contained
syn match au3Send "{LAUNCH_APP2}" contained

"this was tricky!
"we use an oneline region, instead of a match, in order to use skip=
"matchgroup= so start and end quotes are not considered as au3Doubled
"contained
syn region au3String oneline contains=au3Send matchgroup=au3Quote start=+"+
	\ end=+"+ end=+_\n\{1}.*"+
	\ contains=au3Cont,au3DoubledDoubles skip=+""+
syn region au3String oneline matchgroup=au3Quote start=+'+
	\ end=+'+ end=+_\n\{1}.*'+
	\ contains=au3Cont,au3DoubledSingles skip=+''+

syn match au3VarSelector "\$"	contained display
syn match au3Variable "$\w\+" contains=au3VarSelector

" options - must be defined after au3Strings
syn match au3Option "\"CaretCoordMode\""
syn match au3Option "\"ColorMode\""
syn match au3Option "\"ExpandEnvStrings\""
syn match au3Option "\"ExpandVarStrings\""
syn match au3Option "\"FtpBinaryMode\""
syn match au3Option "\"GUICloseOnEsc\""
syn match au3Option "\"GUICoordMode\""
syn match au3Option "\"GUIDataSeparatorChar\""
syn match au3Option "\"GUIOnEventMode\""
syn match au3Option "\"GUIResizeMode\""
syn match au3Option "\"GUIEventCompatibilityMode\""
syn match au3Option "\"MouseClickDelay\""
syn match au3Option "\"MouseClickDownDelay\""
syn match au3Option "\"MouseClickDragDelay\""
syn match au3Option "\"MouseCoordMode\""
syn match au3Option "\"MustDeclareVars\""
syn match au3Option "\"OnExitFunc\""
syn match au3Option "\"PixelCoordMode\""
syn match au3Option "\"RunErrorsFatal\""
syn match au3Option "\"SendAttachMode\""
syn match au3Option "\"SendCapslockMode\""
syn match au3Option "\"SendKeyDelay\""
syn match au3Option "\"SendKeyDownDelay\""
syn match au3Option "\"TCPTimeout\""
syn match au3Option "\"TrayAutoPause\""
syn match au3Option "\"TrayIconDebug\""
syn match au3Option "\"TrayIconHide\""
syn match au3Option "\"TrayMenuMode\""
syn match au3Option "\"TrayOnEventMode\""
syn match au3Option "\"WinDetectHiddenText\""
syn match au3Option "\"WinSearchChildren\""
syn match au3Option "\"WinTextMatchMode\""
syn match au3Option "\"WinTitleMatchMode\""
syn match au3Option "\"WinWaitDelay\""

" styles - must be defined after au3Variable
" common
syn match au3Style "\$WS_BORDER"
syn match au3Style "\$WS_POPUP"
syn match au3Style "\$WS_CAPTION"
syn match au3Style "\$WS_CLIPCHILDREN"
syn match au3Style "\$WS_CLIPSIBLINGS"
syn match au3Style "\$WS_DISABLED"
syn match au3Style "\$WS_DLGFRAME"
syn match au3Style "\$WS_HSCROLL"
syn match au3Style "\$WS_MAXIMIZE"
syn match au3Style "\$WS_MAXIMIZEBOX"
syn match au3Style "\$WS_MINIMIZE"
syn match au3Style "\$WS_MINIMIZEBOX"
syn match au3Style "\$WS_OVERLAPPED"
syn match au3Style "\$WS_OVERLAPPEDWINDOW"
syn match au3Style "\$WS_POPUPWINDOW"
syn match au3Style "\$WS_SIZEBOX"
syn match au3Style "\$WS_SYSMENU"
syn match au3Style "\$WS_THICKFRAME"
syn match au3Style "\$WS_VSCROLL"
syn match au3Style "\$WS_VISIBLE"
syn match au3Style "\$WS_CHILD"
syn match au3Style "\$WS_GROUP"
syn match au3Style "\$WS_TABSTOP"
syn match au3Style "\$DS_MODALFRAME"
syn match au3Style "\$DS_SETFOREGROUND"
syn match au3Style "\$DS_CONTEXTHELP"
" common extended
syn match au3Style "\$WS_EX_ACCEPTFILES"
syn match au3Style "\$WS_EX_APPWINDOW"
syn match au3Style "\$WS_EX_CLIENTEDGE"
syn match au3Style "\$WS_EX_CONTEXTHELP"
syn match au3Style "\$WS_EX_DLGMODALFRAME"
syn match au3Style "\$WS_EX_MDICHILD"
syn match au3Style "\$WS_EX_OVERLAPPEDWINDOW"
syn match au3Style "\$WS_EX_STATICEDGE"
syn match au3Style "\$WS_EX_TOPMOST"
syn match au3Style "\$WS_EX_TRANSPARENT"
syn match au3Style "\$WS_EX_TOOLWINDOW"
syn match au3Style "\$WS_EX_WINDOWEDGE"
syn match au3Style "\$WS_EX_LAYERED"
syn match au3Style "\$GUI_WS_EX_PARENTDRAG"
" checkbox
syn match au3Style "\$BS_3STATE"
syn match au3Style "\$BS_AUTO3STATE"
syn match au3Style "\$BS_AUTOCHECKBOX"
syn match au3Style "\$BS_CHECKBOX"
syn match au3Style "\$BS_LEFT"
syn match au3Style "\$BS_PUSHLIKE"
syn match au3Style "\$BS_RIGHT"
syn match au3Style "\$BS_RIGHTBUTTON"
syn match au3Style "\$BS_GROUPBOX"
syn match au3Style "\$BS_AUTORADIOBUTTON"
" push button
syn match au3Style "\$BS_BOTTOM"
syn match au3Style "\$BS_CENTER"
syn match au3Style "\$BS_DEFPUSHBUTTON"
syn match au3Style "\$BS_MULTILINE"
syn match au3Style "\$BS_TOP"
syn match au3Style "\$BS_VCENTER"
syn match au3Style "\$BS_ICON"
syn match au3Style "\$BS_BITMAP"
syn match au3Style "\$BS_FLAT"
" combo
syn match au3Style "\$CBS_AUTOHSCROLL"
syn match au3Style "\$CBS_DISABLENOSCROLL"
syn match au3Style "\$CBS_DROPDOWN"
syn match au3Style "\$CBS_DROPDOWNLIST"
syn match au3Style "\$CBS_LOWERCASE"
syn match au3Style "\$CBS_NOINTEGRALHEIGHT"
syn match au3Style "\$CBS_OEMCONVERT"
syn match au3Style "\$CBS_SIMPLE"
syn match au3Style "\$CBS_SORT"
syn match au3Style "\$CBS_UPPERCASE"
" list
syn match au3Style "\$LBS_DISABLENOSCROLL"
syn match au3Style "\$LBS_NOINTEGRALHEIGHT"
syn match au3Style "\$LBS_NOSEL"
syn match au3Style "\$LBS_NOTIFY"
syn match au3Style "\$LBS_SORT"
syn match au3Style "\$LBS_STANDARD"
syn match au3Style "\$LBS_USETABSTOPS"
" edit/input
syn match au3Style "\$ES_AUTOHSCROLL"
syn match au3Style "\$ES_AUTOVSCROLL"
syn match au3Style "\$ES_CENTER"
syn match au3Style "\$ES_LOWERCASE"
syn match au3Style "\$ES_NOHIDESEL"
syn match au3Style "\$ES_NUMBER"
syn match au3Style "\$ES_OEMCONVERT"
syn match au3Style "\$ES_MULTILINE"
syn match au3Style "\$ES_PASSWORD"
syn match au3Style "\$ES_READONLY"
syn match au3Style "\$ES_RIGHT"
syn match au3Style "\$ES_UPPERCASE"
syn match au3Style "\$ES_WANTRETURN"
" progress bar
syn match au3Style "\$PBS_SMOOTH"
syn match au3Style "\$PBS_VERTICAL"
" up-down
syn match au3Style "\$UDS_ALIGNLEFT"
syn match au3Style "\$UDS_ALIGNRIGHT"
syn match au3Style "\$UDS_ARROWKEYS"
syn match au3Style "\$UDS_HORZ"
syn match au3Style "\$UDS_NOTHOUSANDS"
syn match au3Style "\$UDS_WRAP"
" label/static
syn match au3Style "\$SS_BLACKFRAME"
syn match au3Style "\$SS_BLACKRECT"
syn match au3Style "\$SS_CENTER"
syn match au3Style "\$SS_CENTERIMAGE"
syn match au3Style "\$SS_ETCHEDFRAME"
syn match au3Style "\$SS_ETCHEDHORZ"
syn match au3Style "\$SS_ETCHEDVERT"
syn match au3Style "\$SS_GRAYFRAME"
syn match au3Style "\$SS_GRAYRECT"
syn match au3Style "\$SS_LEFT"
syn match au3Style "\$SS_LEFTNOWORDWRAP"
syn match au3Style "\$SS_NOPREFIX"
syn match au3Style "\$SS_NOTIFY"
syn match au3Style "\$SS_RIGHT"
syn match au3Style "\$SS_RIGHTJUST"
syn match au3Style "\$SS_SIMPLE"
syn match au3Style "\$SS_SUNKEN"
syn match au3Style "\$SS_WHITEFRAME"
syn match au3Style "\$SS_WHITERECT"
" tab
syn match au3Style "\$TCS_SCROLLOPPOSITE"
syn match au3Style "\$TCS_BOTTOM"
syn match au3Style "\$TCS_RIGHT"
syn match au3Style "\$TCS_MULTISELECT"
syn match au3Style "\$TCS_FLATBUTTONS"
syn match au3Style "\$TCS_FORCEICONLEFT"
syn match au3Style "\$TCS_FORCELABELLEFT"
syn match au3Style "\$TCS_HOTTRACK"
syn match au3Style "\$TCS_VERTICAL"
syn match au3Style "\$TCS_TABS"
syn match au3Style "\$TCS_BUTTONS"
syn match au3Style "\$TCS_SINGLELINE"
syn match au3Style "\$TCS_MULTILINE"
syn match au3Style "\$TCS_RIGHTJUSTIFY"
syn match au3Style "\$TCS_FIXEDWIDTH"
syn match au3Style "\$TCS_RAGGEDRIGHT"
syn match au3Style "\$TCS_FOCUSONBUTTONDOWN"
syn match au3Style "\$TCS_OWNERDRAWFIXED"
syn match au3Style "\$TCS_TOOLTIPS"
syn match au3Style "\$TCS_FOCUSNEVER"
" avi clip
syn match au3Style "\$ACS_AUTOPLAY"
syn match au3Style "\$ACS_CENTER"
syn match au3Style "\$ACS_TRANSPARENT"
syn match au3Style "\$ACS_NONTRANSPARENT"
" date
syn match au3Style "\$DTS_UPDOWN"
syn match au3Style "\$DTS_SHOWNONE"
syn match au3Style "\$DTS_LONGDATEFORMAT"
syn match au3Style "\$DTS_TIMEFORMAT"
syn match au3Style "\$DTS_RIGHTALIGN"
syn match au3Style "\$DTS_SHORTDATEFORMAT"
" monthcal
syn match au3Style "\$MCS_NOTODAY"
syn match au3Style "\$MCS_NOTODAYCIRCLE"
syn match au3Style "\$MCS_WEEKNUMBERS"
" treeview
syn match au3Style "\$TVS_HASBUTTONS"
syn match au3Style "\$TVS_HASLINES"
syn match au3Style "\$TVS_LINESATROOT"
syn match au3Style "\$TVS_DISABLEDRAGDROP"
syn match au3Style "\$TVS_SHOWSELALWAYS"
syn match au3Style "\$TVS_RTLREADING"
syn match au3Style "\$TVS_NOTOOLTIPS"
syn match au3Style "\$TVS_CHECKBOXES"
syn match au3Style "\$TVS_TRACKSELECT"
syn match au3Style "\$TVS_SINGLEEXPAND"
syn match au3Style "\$TVS_FULLROWSELECT"
syn match au3Style "\$TVS_NOSCROLL"
syn match au3Style "\$TVS_NONEVENHEIGHT"
" slider
syn match au3Style "\$TBS_AUTOTICKS"
syn match au3Style "\$TBS_BOTH"
syn match au3Style "\$TBS_BOTTOM"
syn match au3Style "\$TBS_HORZ"
syn match au3Style "\$TBS_VERT"
syn match au3Style "\$TBS_NOTHUMB"
syn match au3Style "\$TBS_NOTICKS"
syn match au3Style "\$TBS_LEFT"
syn match au3Style "\$TBS_RIGHT"
syn match au3Style "\$TBS_TOP"
" listview
syn match au3Style "\$LVS_ICON"
syn match au3Style "\$LVS_REPORT"
syn match au3Style "\$LVS_SMALLICON"
syn match au3Style "\$LVS_LIST"
syn match au3Style "\$LVS_EDITLABELS"
syn match au3Style "\$LVS_NOCOLUMNHEADER"
syn match au3Style "\$LVS_NOSORTHEADER"
syn match au3Style "\$LVS_SINGLESEL"
syn match au3Style "\$LVS_SHOWSELALWAYS"
syn match au3Style "\$LVS_SORTASCENDING"
syn match au3Style "\$LVS_SORTDESCENDING"
" listview extended
syn match au3Style "\$LVS_EX_FULLROWSELECT"
syn match au3Style "\$LVS_EX_GRIDLINES"
syn match au3Style "\$LVS_EX_HEADERDRAGDROP"
syn match au3Style "\$LVS_EX_TRACKSELECT"
syn match au3Style "\$LVS_EX_CHECKBOXES"
syn match au3Style "\$LVS_EX_BORDERSELECT"
syn match au3Style "\$LVS_EX_DOUBLEBUFFER"
syn match au3Style "\$LVS_EX_FLATSB"
syn match au3Style "\$LVS_EX_MULTIWORKAREAS"
syn match au3Style "\$LVS_EX_SNAPTOGRID"
syn match au3Style "\$LVS_EX_SUBITEMIMAGES"

" constants - must be defined after au3Variable - excludes styles
" constants - autoit options
syn match au3Const "\$OPT_COORDSRELATIVE"
syn match au3Const "\$OPT_COORDSABSOLUTE"
syn match au3Const "\$OPT_COORDSCLIENT"
syn match au3Const "\$OPT_ERRORSILENT"
syn match au3Const "\$OPT_ERRORFATAL"
syn match au3Const "\$OPT_CAPSNOSTORE"
syn match au3Const "\$OPT_CAPSSTORE"
syn match au3Const "\$OPT_MATCHSTART"
syn match au3Const "\$OPT_MATCHANY"
syn match au3Const "\$OPT_MATCHEXACT"
syn match au3Const "\$OPT_MATCHADVANCED"
" constants - file
syn match au3Const "\$FC_NOOVERWRITE"
syn match au3Const "\$FC_OVERWRITE"
syn match au3Const "\$FT_MODIFIED"
syn match au3Const "\$FT_CREATED"
syn match au3Const "\$FT_ACCESSED"
syn match au3Const "\$FO_READ"
syn match au3Const "\$FO_APPEND"
syn match au3Const "\$FO_OVERWRITE"
syn match au3Const "\$EOF"
syn match au3Const "\$FD_FILEMUSTEXIST"
syn match au3Const "\$FD_PATHMUSTEXIST"
syn match au3Const "\$FD_MULTISELECT"
syn match au3Const "\$FD_PROMPTCREATENEW"
syn match au3Const "\$FD_PROMPTOVERWRITE"
" constants - keyboard
syn match au3Const "\$KB_SENDSPECIAL"
syn match au3Const "\$KB_SENDRAW"
syn match au3Const "\$KB_CAPSOFF"
syn match au3Const "\$KB_CAPSON"
" constants - message box
syn match au3Const "\$MB_OK"
syn match au3Const "\$MB_OKCANCEL"
syn match au3Const "\$MB_ABORTRETRYIGNORE"
syn match au3Const "\$MB_YESNOCANCEL"
syn match au3Const "\$MB_YESNO"
syn match au3Const "\$MB_RETRYCANCEL"
syn match au3Const "\$MB_ICONHAND"
syn match au3Const "\$MB_ICONQUESTION"
syn match au3Const "\$MB_ICONEXCLAMATION"
syn match au3Const "\$MB_ICONASTERISK"
syn match au3Const "\$MB_DEFBUTTON1"
syn match au3Const "\$MB_DEFBUTTON2"
syn match au3Const "\$MB_DEFBUTTON3"
syn match au3Const "\$MB_APPLMODAL"
syn match au3Const "\$MB_SYSTEMMODAL"
syn match au3Const "\$MB_TASKMODAL"
syn match au3Const "\$MB_TOPMOST"
syn match au3Const "\$MB_RIGHTJUSTIFIED"
syn match au3Const "\$IDTIMEOUT"
syn match au3Const "\$IDOK"
syn match au3Const "\$IDCANCEL"
syn match au3Const "\$IDABORT"
syn match au3Const "\$IDRETRY"
syn match au3Const "\$IDIGNORE"
syn match au3Const "\$IDYES"
syn match au3Const "\$IDNO"
syn match au3Const "\$IDTRYAGAIN"
syn match au3Const "\$IDCONTINUE"
" constants - progress and splash
syn match au3Const "\$DLG_NOTITLE"
syn match au3Const "\$DLG_NOTONTOP"
syn match au3Const "\$DLG_TEXTLEFT"
syn match au3Const "\$DLG_TEXTRIGHT"
syn match au3Const "\$DLG_MOVEABLE"
syn match au3Const "\$DLG_TEXTVCENTER"
" constants - tray tip
syn match au3Const "\$TIP_ICONNONE"
syn match au3Const "\$TIP_ICONASTERISK"
syn match au3Const "\$TIP_ICONEXCLAMATION"
syn match au3Const "\$TIP_ICONHAND"
syn match au3Const "\$TIP_NOSOUND"
" constants - mouse
syn match au3Const "\$IDC_UNKNOWN"
syn match au3Const "\$IDC_APPSTARTING"
syn match au3Const "\$IDC_ARROW"
syn match au3Const "\$IDC_CROSS"
syn match au3Const "\$IDC_HELP"
syn match au3Const "\$IDC_IBEAM"
syn match au3Const "\$IDC_ICON"
syn match au3Const "\$IDC_NO"
syn match au3Const "\$IDC_SIZE"
syn match au3Const "\$IDC_SIZEALL"
syn match au3Const "\$IDC_SIZENESW"
syn match au3Const "\$IDC_SIZENS"
syn match au3Const "\$IDC_SIZENWSE"
syn match au3Const "\$IDC_SIZEWE"
syn match au3Const "\$IDC_UPARROW"
syn match au3Const "\$IDC_WAIT"
" constants - process
syn match au3Const "\$SD_LOGOFF"
syn match au3Const "\$SD_SHUTDOWN"
syn match au3Const "\$SD_REBOOT"
syn match au3Const "\$SD_FORCE"
syn match au3Const "\$SD_POWERDOWN"
" constants - string
syn match au3Const "\$STR_NOCASESENSE"
syn match au3Const "\$STR_CASESENSE"
syn match au3Const "\STR_STRIPLEADING"
syn match au3Const "\$STR_STRIPTRAILING"
syn match au3Const "\$STR_STRIPSPACES"
syn match au3Const "\$STR_STRIPALL"
" constants - tray
syn match au3Const "\$TRAY_ITEM_EXIT"
syn match au3Const "\$TRAY_ITEM_PAUSE"
syn match au3Const "\$TRAY_ITEM_FIRST"
syn match au3Const "\$TRAY_CHECKED"
syn match au3Const "\$TRAY_UNCHECKED"
syn match au3Const "\$TRAY_ENABLE"
syn match au3Const "\$TRAY_DISABLE"
syn match au3Const "\$TRAY_FOCUS"
syn match au3Const "\$TRAY_DEFAULT"
syn match au3Const "\$TRAY_EVENT_SHOWICON"
syn match au3Const "\$TRAY_EVENT_HIDEICON"
syn match au3Const "\$TRAY_EVENT_FLASHICON"
syn match au3Const "\$TRAY_EVENT_NOFLASHICON"
syn match au3Const "\$TRAY_EVENT_PRIMARYDOWN"
syn match au3Const "\$TRAY_EVENT_PRIMARYUP"
syn match au3Const "\$TRAY_EVENT_SECONDARYDOWN"
syn match au3Const "\$TRAY_EVENT_SECONDARYUP"
syn match au3Const "\$TRAY_EVENT_MOUSEOVER"
syn match au3Const "\$TRAY_EVENT_MOUSEOUT"
syn match au3Const "\$TRAY_EVENT_PRIMARYDOUBLE"
syn match au3Const "\$TRAY_EVENT_SECONDARYDOUBLE"
" constants - stdio
syn match au3Const "\$STDIN_CHILD"
syn match au3Const "\$STDOUT_CHILD"
syn match au3Const "\$STDERR_CHILD"
" constants - color
syn match au3Const "\$COLOR_BLACK"
syn match au3Const "\$COLOR_SILVER"
syn match au3Const "\$COLOR_GRAY"
syn match au3Const "\$COLOR_WHITE"
syn match au3Const "\$COLOR_MAROON"
syn match au3Const "\$COLOR_RED"
syn match au3Const "\$COLOR_PURPLE"
syn match au3Const "\$COLOR_FUCHSIA"
syn match au3Const "\$COLOR_GREEN"
syn match au3Const "\$COLOR_LIME"
syn match au3Const "\$COLOR_OLIVE"
syn match au3Const "\$COLOR_YELLOW"
syn match au3Const "\$COLOR_NAVY"
syn match au3Const "\$COLOR_BLUE"
syn match au3Const "\$COLOR_TEAL"
syn match au3Const "\$COLOR_AQUA"
" constants - reg value type
syn match au3Const "\$REG_NONE"
syn match au3Const "\$REG_SZ"
syn match au3Const "\$REG_EXPAND_SZ"
syn match au3Const "\$REG_BINARY"
syn match au3Const "\$REG_DWORD"
syn match au3Const "\$REG_DWORD_BIG_ENDIAN"
syn match au3Const "\$REG_LINK"
syn match au3Const "\$REG_MULTI_SZ"
syn match au3Const "\$REG_RESOURCE_LIST"
syn match au3Const "\$REG_FULL_RESOURCE_DESCRIPTOR"
syn match au3Const "\$REG_RESOURCE_REQUIREMENTS_LIST"
" guiconstants - events and messages
syn match au3Const "\$GUI_EVENT_CLOSE"
syn match au3Const "\$GUI_EVENT_MINIMIZE"
syn match au3Const "\$GUI_EVENT_RESTORE"
syn match au3Const "\$GUI_EVENT_MAXIMIZE"
syn match au3Const "\$GUI_EVENT_PRIMARYDOWN"
syn match au3Const "\$GUI_EVENT_PRIMARYUP"
syn match au3Const "\$GUI_EVENT_SECONDARYDOWN"
syn match au3Const "\$GUI_EVENT_SECONDARYUP"
syn match au3Const "\$GUI_EVENT_MOUSEMOVE"
syn match au3Const "\$GUI_EVENT_RESIZED"
syn match au3Const "\$GUI_EVENT_DROPPED"
syn match au3Const "\$GUI_RUNDEFMSG"
" guiconstants - state
syn match au3Const "\$GUI_AVISTOP"
syn match au3Const "\$GUI_AVISTART"
syn match au3Const "\$GUI_AVICLOSE"
syn match au3Const "\$GUI_CHECKED"
syn match au3Const "\$GUI_INDETERMINATE"
syn match au3Const "\$GUI_UNCHECKED"
syn match au3Const "\$GUI_DROPACCEPTED"
syn match au3Const "\$GUI_DROPNOTACCEPTED"
syn match au3Const "\$GUI_ACCEPTFILES"
syn match au3Const "\$GUI_SHOW"
syn match au3Const "\$GUI_HIDE"
syn match au3Const "\$GUI_ENABLE"
syn match au3Const "\$GUI_DISABLE"
syn match au3Const "\$GUI_FOCUS"
syn match au3Const "\$GUI_NOFOCUS"
syn match au3Const "\$GUI_DEFBUTTON"
syn match au3Const "\$GUI_EXPAND"
syn match au3Const "\$GUI_ONTOP"
" guiconstants - font
syn match au3Const "\$GUI_FONTITALIC"
syn match au3Const "\$GUI_FONTUNDER"
syn match au3Const "\$GUI_FONTSTRIKE"
" guiconstants - resizing
syn match au3Const "\$GUI_DOCKAUTO"
syn match au3Const "\$GUI_DOCKLEFT"
syn match au3Const "\$GUI_DOCKRIGHT"
syn match au3Const "\$GUI_DOCKHCENTER"
syn match au3Const "\$GUI_DOCKTOP"
syn match au3Const "\$GUI_DOCKBOTTOM"
syn match au3Const "\$GUI_DOCKVCENTER"
syn match au3Const "\$GUI_DOCKWIDTH"
syn match au3Const "\$GUI_DOCKHEIGHT"
syn match au3Const "\$GUI_DOCKSIZE"
syn match au3Const "\$GUI_DOCKMENUBAR"
syn match au3Const "\$GUI_DOCKSTATEBAR"
syn match au3Const "\$GUI_DOCKALL"
syn match au3Const "\$GUI_DOCKBORDERS"
" guiconstants - graphic
syn match au3Const "\$GUI_GR_CLOSE"
syn match au3Const "\$GUI_GR_LINE"
syn match au3Const "\$GUI_GR_BEZIER"
syn match au3Const "\$GUI_GR_MOVE"
syn match au3Const "\$GUI_GR_COLOR"
syn match au3Const "\$GUI_GR_RECT"
syn match au3Const "\$GUI_GR_ELLIPSE"
syn match au3Const "\$GUI_GR_PIE"
syn match au3Const "\$GUI_GR_DOT"
syn match au3Const "\$GUI_GR_PIXEL"
syn match au3Const "\$GUI_GR_HINT"
syn match au3Const "\$GUI_GR_REFRESH"
syn match au3Const "\$GUI_GR_PENSIZE"
syn match au3Const "\$GUI_GR_NOBKCOLOR"
" guiconstants - control default styles
syn match au3Const "\$GUI_SS_DEFAULT_AVI"
syn match au3Const "\$GUI_SS_DEFAULT_BUTTON"
syn match au3Const "\$GUI_SS_DEFAULT_CHECKBOX"
syn match au3Const "\$GUI_SS_DEFAULT_COMBO"
syn match au3Const "\$GUI_SS_DEFAULT_DATE"
syn match au3Const "\$GUI_SS_DEFAULT_EDIT"
syn match au3Const "\$GUI_SS_DEFAULT_GRAPHIC"
syn match au3Const "\$GUI_SS_DEFAULT_GROUP"
syn match au3Const "\$GUI_SS_DEFAULT_ICON"
syn match au3Const "\$GUI_SS_DEFAULT_INPUT"
syn match au3Const "\$GUI_SS_DEFAULT_LABEL"
syn match au3Const "\$GUI_SS_DEFAULT_LIST"
syn match au3Const "\$GUI_SS_DEFAULT_LISTVIEW"
syn match au3Const "\$GUI_SS_DEFAULT_MONTHCAL"
syn match au3Const "\$GUI_SS_DEFAULT_PIC"
syn match au3Const "\$GUI_SS_DEFAULT_PROGRESS"
syn match au3Const "\$GUI_SS_DEFAULT_RADIO"
syn match au3Const "\$GUI_SS_DEFAULT_SLIDER"
syn match au3Const "\$GUI_SS_DEFAULT_TAB"
syn match au3Const "\$GUI_SS_DEFAULT_TREEVIEW"
syn match au3Const "\$GUI_SS_DEFAULT_UPDOWN"
syn match au3Const "\$GUI_SS_DEFAULT_GUI"
" guiconstants - background color special flags
syn match au3Const "\$GUI_BKCOLOR_DEFAULT"
syn match au3Const "\$GUI_BKCOLOR_LV_ALTERNATE"
syn match au3Const "\$GUI_BKCOLOR_TRANSPARENT"

" registry constants
syn match au3Const "\"REG_BINARY\""
syn match au3Const "\"REG_SZ\""
syn match au3Const "\"REG_MULTI_SZ\""
syn match au3Const "\"REG_EXPAND_SZ\""
syn match au3Const "\"REG_DWORD\""


" Define the default highlighting.
" Unused colors: Underlined, Ignore, Error, Todo
hi def link au3Function Statement  " yellow/yellow
hi def link au3Keyword Statement
hi def link au3Operator Operator
hi def link au3VarSelector Operator
hi def link au3Comment	Comment  " cyan/blue
hi def link au3Paren Comment
hi def link au3Comma Comment
hi def link au3Bracket Comment
hi def link au3Number Constant " magenta/red
hi def link au3String Constant
hi def link au3Quote Constant
hi def link au3Included Constant
hi def link au3Cont Special  " red/orange
hi def link au3DoubledSingles Special
hi def link au3DoubledDoubles Special
hi def link au3CommDelimiter PreProc  " blue/magenta
hi def link au3Include PreProc
hi def link au3Variable Identifier  " cyan/cyan
hi def link au3Builtin Type  " green/green
hi def link au3Option Type
hi def link au3Style Type
hi def link au3Const Type
hi def link au3Send Type

"syn sync fromstart
syn sync minlines=50
