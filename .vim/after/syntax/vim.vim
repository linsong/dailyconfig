" The default vim syntax file lacks the 'fold' option.
syntax region vimFold start="\<fu\%[nction]!\=\s\+\(<[sS][iI][dD]>\|[Ss]:\|\u\)\i*\ze\s*(" end="\<endf\%[unction]\>" transparent fold keepend extend
setlocal foldmethod=syntax 
