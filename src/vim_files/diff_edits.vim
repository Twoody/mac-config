" ~/.vim/diff_edits.vim
" Define a command that adds headers, footers, and instructions to a diff buffer

command! DiffEdits call DiffEdits()

function! DiffEdits()
  " Add header at the start of the file
  call append(0, ['## diff', '<<<'])

  " Add footer markers at the end of the file
  $put ='>>>'

  " Add instructions after the footer
  $put =''
  $put ='Create a git commit message for this diff. Include a title. Be concise'
endfunction

