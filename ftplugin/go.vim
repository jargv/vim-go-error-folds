let s:folding = 0

command! ToggleGoErrorFolding call <SID>ToggleGoErrorFolding()
func! <SID>ToggleGoErrorFolding()
  if s:folding == 0
    let s:prevFoldmethod = &foldmethod
    let s:prevFoldexpr = &foldexpr
    setlocal foldmethod=expr
    setlocal foldexpr=GetGoErrorFold(v:lnum)
    let s:folding = 1
    normal zM
    echo "go error folding [on]"
  else
    let &foldmethod = s:prevFoldmethod
    let &foldexpr = s:prevFoldexpr
    let s:folding = 0
    normal zR
    echo "go error folding [off]"
  endif
  set debug=msg
endfunc

func! GetGoErrorFold(lnum)
  if a:lnum == 0
    return '-2'
  endif

  let line = getline(a:lnum)
  if line =~ '^\s*$'
    let l = GetGoErrorFold(a:lnum-1)
    return l
  endif

  let nextLine = getline(a:lnum+1)

  "some regexes to use
  let errIf = '^\s*if\ err\ !=\ nil\ {\s*'
  let createsError = 'err :\?='
  let closeBracket = '^\s*}\s*$'

  " the line right before an error handling block starts a fold
  if line =~ createsError && nextLine =~ errIf
    return '>1'
  endif

  " the if err ... line is in the block
  if line =~ errIf
    return '1'
  endif

  "set the position so that searchpair works
  let pos = getpos('.')
  let tempPos = [pos[0], a:lnum, 0, pos[3]]
  call setpos('.', tempPos)
  let blockStartLine = searchpair('{', '', '}', 'bnW')
  call setpos('.', pos)

  "if the current block is an error handling block
  if blockStartLine != 0 && getline(blockStartLine) =~ errIf
    return '1'
  endif

  "otherwise, this is not a fold
  return '0'

endfunc

setlocal foldtext=GetGoErrorFoldText()
func! GetGoErrorFoldText()
  let indent = repeat(' ', &sw*len(v:folddashes)-1)

  "get the line, hide the error var
  let line = getline(v:foldstart)
  let line = substitute(line, ',\ err\ ', ' ', '')
  let line = substitute(line, '\<err\ :\?=\ ', '', '')

  "find the last non-blank line in the fold
  let foldend = v:foldend
  while foldend > v:foldstart
    if getline(foldend) !~ "^\s*$"
      break
    endif

    let foldend -= 1
  endwhile

  "figure out how describe the error handling
  let nLines = foldend - v:foldstart

  let mainLine = getline(v:foldstart + 2)

  "PANIC
  if nLines == 3 && mainLine =~ 'panic'
    let errorHandling = 'PANIC'

    "fmt.Errorf
  elseif nLines == 3 && mainLine =~ 'fmt\.Errorf'
    let args = substitute(mainLine, '^\s*return\ fmt.Errorf(', '', '')
    let args = substitute(args, ')\s*$', '', '')
    let errorHandling = args

    "errors.New
  elseif nLines == 3 && mainLine =~ 'errors\.New'
    let args = substitute(mainLine, '^\s*return\ Errors\.New(', '', '')
    let args = substitute(args, ')\s*$', '', '')
    let errorHandling = args

    "return something else
  elseif nLines == 3 && mainLine =~ 'return'
    let result = substitute(mainLine, '^\s*return\s*', '', '')
    let errorHandling = result

    "something else
  elseif nLines == 3
    let errorHandling = substitute(mainLine, '^\s*', '', '')

    "[handle n lines]
  else
    let errorHandling = "[handle ".nLines." lines]"
  endif

  return indent . line . ' or ' . errorHandling
endfunc
