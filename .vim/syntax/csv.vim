" This is version 1.01
:sy off
:sy on
" TAB is the delimiter
" " is word separator
" no support for escape character
:syntax match end   "	"          nextgroup=col00
:syntax match col13 "	[^	]*"    nextgroup=end
:syntax match col13 "	\"[^"]*\"" nextgroup=end
:syntax match col12 "	[^	]*"    nextgroup=col13
:syntax match col12 "	\"[^"]*\"" nextgroup=col13
:syntax match col11 "	[^	]*"    nextgroup=col12
:syntax match col11 "	\"[^"]*\"" nextgroup=col12
:syntax match col10 "	[^	]*"    nextgroup=col11
:syntax match col10 "	\"[^"]*\"" nextgroup=col11
:syntax match col09 "	[^	]*"    nextgroup=col10
:syntax match col09 "	\"[^"]*\"" nextgroup=col10
:syntax match col08 "	[^	]*"    nextgroup=col09
:syntax match col08 "	\"[^"]*\"" nextgroup=col09
:syntax match col07 "	[^	]*"    nextgroup=col08
:syntax match col07 "	\"[^"]*\"" nextgroup=col08
:syntax match col06 "	[^	]*"    nextgroup=col07
:syntax match col06 "	\"[^"]*\"" nextgroup=col07
:syntax match col05 "	[^	]*"    nextgroup=col06
:syntax match col05 "	\"[^"]*\"" nextgroup=col06
:syntax match col04 "	[^	]*"    nextgroup=col05
:syntax match col04 "	\"[^"]*\"" nextgroup=col05
:syntax match col03 "	[^	]*"    nextgroup=col04
:syntax match col03 "	\"[^"]*\"" nextgroup=col04
:syntax match col02 "	[^	]*"    nextgroup=col03
:syntax match col02 "	\"[^"]*\"" nextgroup=col03
:syntax match col01 "	[^	]*"    nextgroup=col02
:syntax match col01 "	\"[^"]*\"" nextgroup=col02
:syntax match col00 "[^	]*"        nextgroup=col01
:syntax match col00 "\"[^"]*\""    nextgroup=col01
:syntax match start "^"            nextgroup=col00

:hi col13 ctermfg=gray
:hi col12 ctermfg=darkyellow
:hi col11 ctermfg=darkcyan
:hi col10 ctermfg=darkmagenta
:hi col09 ctermfg=darkgreen
:hi col08 ctermfg=darkred
:hi col07 ctermfg=darkblue
:hi col06 ctermfg=white
:hi col05 ctermfg=yellow
:hi col04 ctermfg=cyan
:hi col03 ctermfg=magenta
:hi col02 ctermfg=green
:hi col01 ctermfg=red
:hi col00 ctermfg=blue

