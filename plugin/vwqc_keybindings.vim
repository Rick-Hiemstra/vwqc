" -----------------------------------------------------------------
" ------------------ VWQC PLUG-IN KEYBINDINGS ---------------------
" -----------------------------------------------------------------

" --------------- Go To Interview Line ----------------------------
nnoremap <leader>gt :call g:GoToReference()<CR>

" --------------- Go back to the page selected by GoToReference()
nnoremap <leader>gb :call g:GoBackFromReference()<CR>

" --------------- Call Annotation()
nnoremap <F7> :call AnnotationToggle()<CR>
inoremap <F7> <ESC>:call AnnotationToggle()<CR>

" -------------- Delete Annotation ----------------------------------------
nnoremap <leader>da :call DeleteAnnotation()<CR>

" -------------- Fill Tags ----------------------------------------
nnoremap <leader>tf ?:<CR>vf:ykV?<C-R>"<CR>j:'<,'>normal A <C-R>"<CR>j$

" - Resize open windows so that the leftmost is 60 characters wide.
nnoremap <leader>rs <C-W>h<C-W>h:vertical resize 60<CR><C-W>l

" --------------- Copy block quote within VWQC ----------------------
"vnoremap <leader>cv f\|hy<ESC>:cd %:p:h<CR>:sp new<CR>pggVGJ:s/\s\{2,}/ /g<CR>Vy:q!<CR>
vnoremap <leader>cv f│hy<ESC>:cd %:p:h<CR>:sp new<CR>pggVGJ:s/\s\{2,}/ /g<CR>Vy:q!<CR>

" ---------------- Call TagLinter() -------------------------------
nnoremap <leader>tl :call TagLinter()<CR>

" ---------------- Add New Tags to g:current_tags -------------------------------
nnoremap <F2> :call GetTagUpdate()<CR>

" ---------------- Call Popup Help Menu  -------------------------------
nnoremap <leader>hm :call HelpMenu()<CR>

" ---------------- Call Popup Help Menu  -------------------------------
nnoremap <leader>ph :call PageHelp()<CR>

" ---------------- Call ListProjectParameters -------------------------------
nnoremap <leader>lp :call ListProjectParameters()<CR>

" ---------------- Get Tag Definition  -------------------------------
nnoremap <leader>df :call GetTagDef()<CR>

" ---------------- Call omni-complete -----------------------------
"inoremap <F8> <C-x><C-o>
"inoremap <F9> <C-x><C-o>
"nnoremap <F8> :execute "normal! a<C-x><C-o><CR>"
inoremap <F8> <ESC>:call TagsGenThisSession()<CR>
inoremap <F9> <ESC>:call TagsGenThisSession()<CR>
"inoremap <nowait> :: <ESC>a:<ESC>:call TagsGenThisSession()<CR>
nnoremap <leader>tc :call ToggleDoubleColonOmniComplete()<CR>


xnoremap <leader>t y:call TagFill()<CR>
inoremap <C-S-h> <C-x><C-o>

" ---------------- Create Project Backup ---------------------
nnoremap <leader>bk :call CreateBackupQuery()<CR>	

" ----- Select tag from omni-complete list and close tag ending in normal mode---------
"inoremap <Right> :<ESC>
inoremap <C-S-l> :<ESC>


" ---------------- Move up and down in omni-complete window: ---------------------
inoremap <Up> <C-p>
inoremap <Down> <C-n>
inoremap <C-S-k> <C-p>
inoremap <C-S-j> <C-n>

" ---------------- Toggle Tag Fill Option ---------------------
nnoremap <F4> :call ChangeTagFillOption()<CR>	
inoremap <F4> <ESC>:call ChangeTagFillOption()<CR>

" ---------------- Fill Tag Block ---------------------
nnoremap <F5> :call TagFillWithChoice()<CR>	
inoremap <F5> <ESC>:call TagFillWithChoice()<CR>

" ----------- Trim Partial Leading and Trailing Sentences -----
" --- Trim Leading (trim head = <leader>th --------------------
nnoremap <leader>th :call TrimLeadingPartialSentence()<CR>
" --- Trim Trailing (trim trailing = <leader>tt ----------------
nnoremap <leader>tt :call TrimTrailingPartialSentence()<CR>
" --- Trim both leading and trailing sentences (trim all = <leader>ta)
nnoremap <leader>ta :call TrimLeadingAndTrailingPartialSentence()<CR>
"nnoremap <leader>ta :call TrimTrailingPartialSentence()<CR>:callTrimLeadingPartialSentence()<CR>

" -----------------------------------------------------------------
" ------------------ VWQC Settings ---------------------
" -----------------------------------------------------------------

" ----------- Required to make us of the par utility -----
set formatprg=par\ w80

" ----------- Sets some vimwiki behaviors -----
let g:vimwiki_global_ext = 0
let g:vimwiki_url_maxsave = 0
let g:vimwiki_auto_update_tags = 0
