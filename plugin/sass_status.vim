if exists('g:autoloaded_sass_status') || &cp
  finish
endif

let g:autoloaded_sass_status = '1'

let s:cpo_save = &cpo
set cpo&vim

function! sass_status#statusline(...)
  "let save_view = winsaveview() " save view state so we can move around freely

  try
    let indent = indent('.')
    let status = ''
    let line_num = line('.') - 1
    while indent > 0 && line_num > 0
      let line_num = prevnonblank(line_num)
      let current_indent = indent(line_num)
      if current_indent < indent
        let line = getline(line_num)
        let line = substitute(line, '^\s\+', '', '')
        let line = substitute(line, '\s\+$', '', '')

        if line =~ ','
          let line = '('.line.')'
        endif

        let status = line.' '.status
        let indent = current_indent
      endif

      let line_num = line_num - 1
    endwhile

    let status = substitute(status, '\s\+$', '', '')
    let status = substitute(status, ' &', '', '')

    if strlen(status) > 0
      let status = '{'.status.'}'
    endif

    return status
  finally
    "call winrestview(save_view)
  endtry
endfunction

function! s:addtostatus(letter,status)
  let status = a:status
  if status !~ 'sass' && status !~ '^%!'
    let separator = ''

    let   status=substitute(status,'\C%'.tolower(a:letter),'%'.tolower(a:letter).'%{sass_status#statusline()}','')
    if status !~ 'sass'
      let status=substitute(status,'\C%'.toupper(a:letter),'%'.toupper(a:letter).'%{sass_status#statusline()}','')
    endif
  endif
  return status
endfunction

function! s:InjectIntoStatusline(status)
  let status = a:status
  if status !~ 'sass'
    let status = s:addtostatus('f',status)
    let status = s:addtostatus('y',status)
    let status = s:addtostatus('r',status)
    let status = s:addtostatus('m',status)
    let status = s:addtostatus('w',status)
    let status = s:addtostatus('h',status)
    if status !~ 'sass'
      let status=substitute(status,'%=','%{sass_status#statusline()}%=','')
    endif
    if status !~ 'sass' && status != ''
      let status .= '%{sass_status#statusline()}'
    endif
  endif
  return status
endfunction

function! s:BufInitStatusline()
  if &l:statusline == ''
    let &l:statusline = &g:statusline
  endif
  if &l:statusline == ''
    let &l:statusline='%<%f %h%m%r%='
    if &ruler
      let &l:statusline .= '%-14.(%l,%c%V%) %P'
    endif
  endif
  let &l:statusline = s:InjectIntoStatusline(&l:statusline)
endfunction

augroup sassStatusAuto
  autocmd!
  autocmd BufNewFile,BufRead *.sass call s:BufInitStatusline()
augroup END

let &cpo = s:cpo_save
