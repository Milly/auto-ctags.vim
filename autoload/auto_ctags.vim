" Vim global plugin for Create ctags
" Last Change: 2013 Dec 17
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:autoloaded_auto_ctags")
  finish
endif
let g:autoloaded_auto_ctags = 1

let s:save_cpo = &cpo
set cpo&vim

"------------------------
" setting
"------------------------
if !exists("g:auto_ctags")
  let g:auto_ctags = 0
endif

if !exists("g:auto_ctags_directory_list")
  let g:auto_ctags_directory_list = ['.']
endif

if !exists("g:auto_ctags_tags_name")
  let g:auto_ctags_tags_name = 'tags'
endif

if !exists("g:auto_ctags_bin_path")
  let g:auto_ctags_bin_path = 'ctags'
endif

if !exists("g:auto_ctags_tags_args")
  let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes'
endif

if !exists("g:auto_ctags_filetype_mode")
  let g:auto_ctags_filetype_mode = 0
endif

if !exists("g:auto_ctags_search_recursively")
  let g:auto_ctags_search_recursively = 0
endif

"------------------------
" function
"------------------------
function! auto_ctags#ctags_path()
  let path = ''
  for directory in g:auto_ctags_directory_list
    if g:auto_ctags_search_recursively > 0
      let dirs = finddir(directory, escape(expand('<afile>:p:h'), ' ') . ';', -1)
      if !empty(dirs)
        let directory = dirs[0]
      endif
    endif
    if isdirectory(directory)
      let tags_name = g:auto_ctags_tags_name
      if g:auto_ctags_filetype_mode > 0
        if &filetype !=# ''
          let tags_name = &filetype.'.'.tags_name
        endif
      endif
      let path = directory.'/'.tags_name
      break
    endif
  endfor

  return path
endfunction

function! auto_ctags#ctags_lock_path()
  let path = auto_ctags#ctags_path()
  if len(path) > 0
    let path = path.'.lock'
  endif
  return path
endfunction

function! auto_ctags#ctags_cmd_opt()
  let opt = g:auto_ctags_tags_args
  if g:auto_ctags_filetype_mode > 0
      if &filetype ==# 'cpp'
        let opt = opt.' --languages=c++'
      elseif &filetype !=# ''
        let opt = opt.' --languages='.&filetype
      endif
  endif
  return opt
endfunction

function! auto_ctags#ctags_cmd()
  let ctags_cmd = ''
  let tags_bin_path = g:auto_ctags_bin_path

  let tags_path = auto_ctags#ctags_path()
  let tags_lock_name = auto_ctags#ctags_lock_path()
  if len(tags_path) > 0 && glob(tags_lock_name) == ''
    let ctags_cmd = 'touch '.tags_lock_name.' && '
          \.tags_bin_path.' '.auto_ctags#ctags_cmd_opt().' -f '.tags_path.' && '
          \.'rm '.tags_lock_name
  endif

  return ctags_cmd
endfunction

function! auto_ctags#ctags(recreate)
  if g:auto_ctags ==# 0 && a:recreate ==# 0
    return
  endif
  if a:recreate > 0
    silent! execute '!rm '.auto_ctags#ctags_path().' 2>/dev/null'
    silent! execute '!rm '.auto_ctags#ctags_lock_path().' 2>/dev/null'
  endif

  let cmd = auto_ctags#ctags_cmd()
  if len(cmd) > 0
    silent! execute '!sh -c "'.cmd.'" 2>/dev/null &'
  endif

  if a:recreate > 0
    redraw!
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
