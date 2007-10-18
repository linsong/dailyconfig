if exists("rectcut") || &cp
    finish
endif
"""""""""""""""""""""" Commands VIM
command! -nargs=* ColCopy    call ColCopy(<f-args>)
command! -nargs=* Cut       :call s:RectCut(<f-args>)
command! -nargs=* Pas       :call s:RectPaste(<f-args>)
command! -nargs=* Paste     :call s:RectPaste(<f-args>)
""""""""""""""""""""""
let g:CutList=[]

" The function Nr2Hex() returns the Hex string of a number.
func s:Nr2Hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunc

" The function String2Hex() converts each character in a string to a two
" character Hex string.
func! s:String2Hex(str)
  let out = ''
  let ix = 0
  while ix < strlen(a:str)
    let out = out . s:Nr2Hex(char2nr(a:str[ix]))
    let ix = ix + 1
  endwhile
  return out
endfunc

" The function TrimString() removes white spaces
func! s:TrimString(str)
  let out = ''
  let ix = 0
  while ix < strlen(a:str)
    if(a:str[ix]==' ')
    else
    let out = out . a:str[ix]
    endif
    let ix = ix + 1
  endwhile
  return out
endfunc

func! s:Stuff(str,justif,fillchar,len)
  let out = a:str
  let intendedlen  = a:len
  let left_or_right = a:justif
  let fillch=a:fillchar

  while intendedlen > strlen(out)
    if left_or_right > 0 
        let out = out . fillch
    else
        let out = fillch . out
    endif
  endwhile
  return out
endfunc

func! ColCopy(...)

   let x1=0
   let y1=0
   let x2=0
   let y2=0
   let k=0
   let re=''

   if a:0 > 0
       while k < a:0
            let re = re . ' ' . a:000[k]
            let k=k+1
       endw
       echo re
   endif
   if ((k==0) || (k==4))
   else
     echo "minimum 4 or 0 arguments"
     return
   endif
   if((x2<x1) || (y2<y1))
     echo "Invalid x and y cordinates"
     echo "x2>x1 and y2>y1"
     echo "example: Cut 2(x1) 3(y1) 4(x2) 5(y2)"
     return
   endif

    if(k==4) 
        let s=line('.')
        let start=line("1")
        let end=line("$")
        let longtestlen=0

        while (start <= end)
            let len = strlen(getline(start))

            if(len > longtestlen)
                let longtestlen=len
            endif

            let start = start + 1
        endwhile

        let beautymargin=longtestlen+1
        let start=line("1")

        while (start <= end)
            let str = getline(start)
            let src_op1=getline(start)
            let src_op2=getline(start)
            "let len=strlen(x)

            let src_op1=s:Stuff(src_op1,1," ",beautymargin)
            let result_string=(src_op1 . src_op2)

            call setline(start,result_string)
            let start = start + 1
            endwhile
            exe ':' . s
    else
        "let start=line(".") " From current line
        let s=line('.')
        let start=line("1")
        let end=line("$")
        let longtestlen=0

        while (start <= end)
            let len = strlen(getline(start))

            if(len > longtestlen)
                let longtestlen=len
            endif

            let start = start + 1
        endwhile

        let beautymargin=longtestlen+1
        let start=line("1")

        while (start <= end)
            let str = getline(start)
            let src_op1=getline(start)
            let src_op2=getline(start)
            "let len=strlen(x)

            let src_op1=s:Stuff(src_op1,1," ",beautymargin)
            let result_string=(src_op1 . src_op2)

            call setline(start,result_string)
            let start = start + 1
            endwhile
            exe ':' . s
    endif

endfunc

function! s:GetNthItemFromList(list, n) 
   let itemStart = 0
   let itemEnd = -1
   let pos = 0
   let item = ""
   let i = 0
   while (i != a:n)
      let itemStart = itemEnd + 1
      let itemEnd = match(a:list, ",", itemStart)
      let i = i + 1
      if (itemEnd == -1)
         if (i == a:n)
            let itemEnd = strlen(a:list)
         endif
         break
      endif
   endwhile 
   if (itemEnd != -1) 
      let item = strpart(a:list, itemStart, itemEnd - itemStart)
   endif
   return item 
endfunction

"set statusline=%<%f%<%<%h%m%r%=%(l=%l,c=%c%V,B=%02B,(%L%),off=%o)\%h%m%r%=%{CurTime()}

fun! s:RectCut(...)

   let x=0

   let x1=0
   let y1=0
   let x2=0
   let y2=0

   if  a:0 == 0
      let x=1
   elseif a:0 == 1
      let re=a:1
   else
       let re=''
       let k = 0
       while k < a:0
            let re = re . ' ' . a:000[k]
            if k==0
                let startl=a:000[k]
                "echo k . ' ' . startl
            elseif k==1
                let startc=a:000[k]-1
                "echo k . ' ' . startc
            elseif k==2
                let endl=a:000[k]+1
                "echo k . ' ' . endl
            elseif k==3
                let endc=a:000[k]-1
                "echo k . ' ' . endc
            endif

            let k=k+1
       endw
   endif
        "call cursor(endl,endc)
        "sleep 500m

        "s:CurPos(startl,startc)
        "s:CurPos(endl,endc)
        let sc=startc
        let ec=endc
        let counter1=endl-startl
        let xinit=0
        let yinit=0
        let g:CutList=[]

        while counter1
            "echo counter1
            let counter2=endc-startc
            while counter2
                if xinit==0
                    let @l=getline(startl)[startc]
                    let x=getline(startl)[startc]
                    let linestr=x
                    "let @b= '(' . startl . ',' . startc .')' . x
                    let startc=startc+1
                    let xinit=1
                else
                    let @L=getline(startl)[startc]
                    let x=getline(startl)[startc]
                    let linestr=linestr . x
                    "let @B= '(' . startl . ',' . startc .')' . x
                    let startc=startc+1
                endif
                let counter2=endc-startc
            endw

            call add(g:CutList,linestr)
            let linestr=''
            let @L= "\n"
            let startl=startl+1
            let counter1=endl-startl
            let startc=sc
            let endc=ec
       endw


   if x == 0
     "echo "result is stored in a register"
     "echo startl . ' ' . endl . ' ' . startc . ' ' . endc
   else
     "echo "No argument supplied"
   endif

endfun


""""""""""""""""""""""
fun! s:RectPaste(...)

   let x=0

   let x1=0
   let y1=0
   let x2=0
   let y2=0

   " Extract variable arguments
   if  a:0 == 0
      let x=1
   elseif a:0 == 1
      let re=a:1
      let startl=a:1
   else
       let re=''
       let k = 0
       while k < a:0
            let re = re . ' ' . a:000[k]
            if k==0
                let startl=a:000[k]
            elseif k==1
                let startc=a:000[k]
            endif

            let k=k+1
       endw
   endif

        let mrk=startl
        let xinit=0
        let x=@a
        let re=@a

   " Determine max length of string
        let maxlen=0
        for var in g:CutList
          let result_string=strpart(getline(startl),0)

          let lng=strlen(result_string)
          if (lng > maxlen)
            let maxlen=lng
          endif
          let startl=startl+1
        endfor

        let startl=mrk

   " Now paste it in each line
        for var in g:CutList

   "Stuff empty space to look more beautifull

          let result_string=strpart(getline(startl),0)
          let result_string=s:Stuff(result_string,1," ",maxlen+1)
          let result_string=result_string . ' ' . var
          call setline(startl,result_string)

          let startl=startl+1

        endfor

        return
endfun


