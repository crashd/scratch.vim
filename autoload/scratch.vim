" scratch.vim autoload

function! scratch#open(reset)
  " open scratch buffer
  let scr_bufnum = bufnr('__Scratch__')
  if scr_bufnum == -1
    execute 'new __Scratch__'
    call s:on_open_scratch(1)
  else
    let scr_winnum = bufwinnr(scr_bufnum)
    if scr_winnum != -1
      if winnr() != scr_winnum
        execute scr_winnum . "wincmd w"
      endif
    else
      execute "split +buffer" . scr_bufnum
      call s:on_open_scratch(0)
    endif
    if a:reset
      silent execute '%d'
    endif
  endif
endfunction

function! scratch#add_and_open(reset) range
  " open scratch buffer with current line selection
  let selected_lines = getline(a:firstline, a:lastline)
  call scratch#open(a:reset)
  let current_scratch_line = line('$')
  if !strlen(getline(current_scratch_line))
    " line is empty, we overwrite it
    let current_scratch_line -= 1
  endif
  call append(current_scratch_line, selected_lines)
  silent execute 'normal! G'
endfunction

function! s:on_open_scratch(fresh)
  " size window appropriately, etc.
  execute 'wincmd K'
  execute 'resize ' . g:scratch_height
  if a:fresh
    let b:autoclose = 1
    setlocal bufhidden=hide
    setlocal buflisted
    setlocal buftype=nofile
    setlocal nonumber
    setlocal noswapfile
    setlocal winfixheight
    augroup scratch
      autocmd!
      autocmd BufEnter __Scratch__ call s:on_enter_scratch()
      if g:scratch_autohide
        autocmd BufLeave __Scratch__ close
      endif
    augroup end
  endif
endfunction

function! s:on_enter_scratch()
  " quit if scratch is last window open (or close tab)
  if winbufnr(2) ==# -1
    if tabpagenr('$') ==# 1
      bdelete
      quit
    else
      close
    endif
  endif
endfunction