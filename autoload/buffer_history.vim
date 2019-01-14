let s:jumping = 0

function! buffer_history#guard()
  if !exists('w:buffer_history')
    let w:buffer_history = []
    let w:buffer_history_index = -1
  endif
endfunction

" Assume the buffer history list are ordered based on their last use, any last
" add behavior will pop the entry to pop
function! buffer_history#add(bufnr) abort "{{{1
  if s:jumping | return | endif
  call buffer_history#guard()
  let index = 0
  if bufexists(a:bufnr)
    let bindex = index(w:buffer_history, a:bufnr)
    if bindex >= 0
      call remove(w:buffer_history, bindex)
    endif
    let w:buffer_history_index = index
    call insert(w:buffer_history, a:bufnr, index)
  endif
endfunction

function! buffer_history#remove(bufnr) "{{{1
  call buffer_history#guard()
  call filter(w:buffer_history, 'v:val !=# a:bufnr')
  if w:buffer_history_index >= len(w:buffer_history)
    let w:buffer_history_index = len(w:buffer_history) - 1
  endif
endfunction

" -1 backward ; 1 forward
function! buffer_history#jump(current_bufnr, dirn) abort "{{{1
  call buffer_history#guard()
  let bindex = index(w:buffer_history, a:current_bufnr)
  if bindex >= 0
      let w:buffer_history_index = bindex
      let index = w:buffer_history_index - (a:dirn * v:count1)
  else
      let index = w:buffer_history_index
  endif
  
  if index >= 0 && index < len(w:buffer_history)
    if bufexists(w:buffer_history[index])
      let w:buffer_history_index = index
      let s:jumping = 1
      exec 'buffer' w:buffer_history[index]
      let s:jumping = 0
      return
    else
      call buffer_history#remove(w:buffer_history[index])
    endif
  endif
  echo 'Reached' (-a:dirn > 0 ? 'end' : 'start') 'of buffer history'
endfunction

function! buffer_history#list() "{{{1
  call buffer_history#guard()
  let history = copy(w:buffer_history)
  let history = map(history, "printf('%3d %1s %-10s', v:val, v:key == w:buffer_history_index ? '*': ' ', bufname(v:val))")
  return history
endfunction
