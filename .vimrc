filetype plugin indent on
set tabstop=3
set shiftwidth=3
set expandtab

*:always in :set paste mode*
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
     set pastetoggle=<Esc>[201~
       set paste
         return ""
      endfunction
