"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer:
"   Brandon Richardson
"
" Mappings:
"   File Management:
"       Save As Root: :w!!
"       Rename File: :rn
"   Tabs:
"       Next Tab: tn :tabnext<Space>
"       Previous Tab: tp :tabprev<Space>
"       Edit In New Tab: te :tabe<Space>
"   Editing:
"       Duplicate Line: Ctrl-d
"       Reverse Indent: Shift-Tab
"   Other:
"   	Render Markdown to PDF: :Render <optional dest file>
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

" Show a line length guide
set colorcolumn=80

" Enable filetype plugins
filetype plugin indent on

" Set to auto read when a file is changed from the outside
set autoread

set path+=**

" Write as root
cmap w!! w !sudo tee > /dev/null %

" Tab shortcut remap
nnoremap tn :tabnext<Space>
nnoremap tp :tabprev<Space>
nnoremap te :tabe<Space>

" Tab and de-tab
" nnoremap <S-Tab> <<
inoremap <S-Tab> <C-d>

" Allow cursor wrap on normal and insert mode
set whichwrap=<,>,[,]

" Auto add matching braces in insert mode
inoremap { {}<Left>
inoremap <expr> } SkipClosingBrace("}")

inoremap [ []<Left>
inoremap <expr> ] SkipClosingBrace("]")

inoremap ( ()<Left>
inoremap <expr> ) SkipClosingBrace(")")

inoremap <expr> <CR> BraceCompletionHelper()

" Backspace in normal mode will delete character and enter insert mode 
nnoremap <C-h> xi


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set scrolloff such that there are always at least seven lines
" visible before and after the cursor when using j/k
set so=7

" Turn on the WiLd menu
set wildmenu

" Wild menu ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Always show line numbers
set number

"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Enable 256 colors palette in Gnome Terminal
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

try
    colorscheme default
catch
endtry

set background=dark

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Be smart when using tabs
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr

set ai "Auto indent
set wrap "Wrap lines


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2
set noshowmode

" Format the status line
set statusline=
set statusline+=%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}
set statusline+=%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}
set statusline+=%#DiffDelete#%{(mode()=='r')?'\ \ RPLACE\ ':''}
set statusline+=%#Cursor#%{(mode()=='v')?'\ \ VISUAL\ ':''}
set statusline+=\ %n\           " buffer number
set statusline+=%#Visual#       " colour
set statusline+=%{&paste?'\ PASTE\ ':''}
set statusline+=%{&spell?'\ SPELL\ ':''}
set statusline+=%#CursorIM#     " colour
set statusline+=%R                        " readonly flag
set statusline+=%M                        " modified [+] flag
set statusline+=%#Cursor#               " colour
set statusline+=%#CursorLine#     " colour
set statusline+=\ %t\                   " short file name
set statusline+=%=                          " right align
set statusline+=%#CursorLine#   " colour
set statusline+=\ %Y\                   " file type
set statusline+=%#CursorIM#     " colour
set statusline+=\ %3l:%-2c\         " line + column
set statusline+=%#Cursor#       " colour
set statusline+=\ %3p%%\                " percentage


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete trailing white space on save
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Add :rn command to rename current file
command! -nargs=1 -complete=file Rn :call Rename(<f-args>)

function! Rename(newfilename)
    let l:oldfilename = @%
    execute "saveas " . a:newfilename . " | call delete(\"" . oldfilename . "\")"
endfunction

function! BraceCompletionHelper()
    let l:last = getline(".")[col(".")-2:col(".")-1]
    if l:last=="{}" || l:last=="[]" || l:last=="()"
        return "\<CR>\<ESC>\k\o"
    else
        return "\<CR>"
    endif
endfunction

function! SkipClosingBrace(brackettype)
    if a:brackettype == ")"
        if strpart(getline('.'), col('.')-1, 1) == ")"
            return "\<Right>"
        endif
    elseif a:brackettype == "}"
        if strpart(getline('.'), col('.')-1, 1) == "}"
            return "\<Right>"
        endif
    elseif a:brackettype == "]"
        if strpart(getline('.'), col('.')-1, 1) == "]"
            return "\<Right>"
        endif
    endif

    return a:brackettype
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Markdon Pandoc Renderer
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if executable("pandoc") == 1
	" Add :Render command to render markdown to pdf using Pandoc
	command! -nargs=? -complete=file Render :call RenderMarkdown(<f-args>) 
	
	function! RenderMarkdown(...) abort
		if a:0 == 1
			" write buffer to stdin of pandoc
			execute "write !pandoc -V geometry:margin=2cm -f markdown -t pdf --pdf-engine=xelatex -V mainfont=\"Latin Modern Math\" -o " . shellescape(a:1)

			if v:shell_error != 0
				return
			endif

			" open file
			silent execute "!open -a Preview " . shellescape(a:1)
		elseif a:0 == 0
			" write buffer to stdin of pandoc with output to temporary file
	
			let l:tmpfile = tempname()
			execute "write !pandoc -V geometry:margin=2cm -f markdown -t pdf --pdf-engine=xelatex -o " . l:tmpfile

			if v:shell_error != 0
				return
			endif

			" open file
			silent execute "!open -a Preview " . l:tmpfile
		else
			throw "RenderMarkdown: Unexpected number of arguments: " . a:0
		endif
	endfunction
else
	command! -nargs=? -complete=file Render :echoerr "Unable to locate pandoc executable. Is pandoc installed?"
endif
