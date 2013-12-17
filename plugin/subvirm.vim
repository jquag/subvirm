command! SvnStatus call SvnStatus()
command! SvnDiff call SvnCompare()
command! -nargs=1 SvnCommit !svn commit -m <args>
command! SvnRevert call SvnRevert(@%, 1)
command! SvnAdd call SvnAdd(@%, 1)
command! SvnAnnotate call SvnAnnotate(@%, line("."))
command! SvnIgnore call SvnIgnore(@%)

function! s:setupScratchBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    nmap <buffer> q :q<CR>
endfunction

function! SvnAnnotate(toAnnotate, lineNbr)
    set scrollbind
    execute "30vs " . a:toAnnotate . "--annotated"
    setlocal nowrap
    set scrollbind
    call s:setupScratchBuffer()
    setlocal syntax=subvirm_annotated
    execute "silent %! svn ann " . a:toAnnotate 
    execute ":" . a:lineNbr
    nmap <buffer> <CR> :call SvnLogFromAnnotate()<CR>
endfunction

function! SvnLogFromAnnotate()
    let revision = matchstr(getline("."), '\d\+')
    let theFile = @%[0:len(@%)-len(" --annotated")]
    execute "to 5sp " . theFile . "@" . revision . "--log"
    call s:setupScratchBuffer()
    set noscrollbind
    setlocal syntax=subvirm_log
    setlocal wfh
    execute "silent %! svn log " . theFile . "@" . revision . " -l 1"
endfunction

function! SvnStatus()
    botright 50vnew SvnStatus
    call s:setupScratchBuffer()
    setlocal syntax=subvirm_status
    setlocal nowrap
    setlocal noautoindent
    call SvnRefreshStatus(0)
    nmap <buffer> + :call SvnScheduleFromStatus()<CR>
    nmap <buffer> D :call SvnCompareFromStatus()<CR>
    nmap <buffer> R :call SvnRefreshStatus(line('.'))<CR>
    nmap <buffer> <CR> :call SvnOpenFileFromStatus()<CR>
    nmap <buffer> - :call SvnRevertOrIgnoreFromStatus()<CR>
endfunction

function! SvnIgnore(toIgnore)
    if has("gui_running")
        if has("mac")
            let cmd = 'mvim'
        else
            let cmd = 'gvim'
        endif
    else
        let cmd = 'vim'
    endif

    let filePath = a:toIgnore
    let lastSeparator = matchend(filePath, '.*/')
    if lastSeparator == -1 
        let fileName = filePath
        let folderName = '.'
    else 
        let fileName = filePath[lastSeparator : len(filePath)]
        let folderName = filePath[0 : lastSeparator-2]
    endif
    execute "silent !svn propedit svn:ignore --editor-cmd \"" . cmd . " -f -c 'normal Go" . fileName . "'\" " . folderName 
    redraw!
endfunction

function! SvnRefreshStatus(lineNbr)
    silent %! svn st
    normal ggO -------------------------------------------
    normal o| 
    normal o| q     quit
    normal o| R     refresh view
    normal o| <CR>  open file in a new tab
    normal o| D     compare file with latest
    normal o| +     schedule file for addition/deletion
    normal o| -     revert or ignore file
    normal o| 
    normal o ---------------------------------------------
    normal o
    execute ':' . a:lineNbr
endfunction

function! SvnOpenFileFromStatus()
    let l = getline('.')[0:0]
    if l == '?' || l == 'M' || l == 'A'
        execute "tabe " . eval("strpart(getline('.'), 8)") 
    else
        echo "nothing to open"
    endif
endfunction

function! SvnScheduleFromStatus()
    if getline('.')[0:0] == '?'
        call SvnAdd(eval("strpart(getline('.'), 8)"), 0)
        call SvnRefreshStatus(line('.'))
    elseif getline('.')[0:0] == '!'
        execute "!svn delete " . eval("strpart(getline('.'), 8)")
        redraw!
        call SvnRefreshStatus(line('.'))
    else
        echo "nothing to add"
    endif
endfunction


function! SvnCompareFromStatus()
    if getline('.')[0:0] == 'M'
        execute "tabe " . eval("strpart(getline('.'), 8)")
        call SvnCompare()
    else
        echo "nothing to compare"
    endif
endfunction

function! SvnRevertOrIgnoreFromStatus()
    let l = getline('.')[0:0] 
    let theFile = strpart(getline('.'), 8)
    if l == 'M' || l == 'A' || l == 'D'
        call SvnRevert(theFile, 0)
        call SvnRefreshStatus(line('.'))
    elseif l == '?'
        call SvnIgnore(theFile)
        call SvnRefreshStatus(line('.'))
    endif
endfunction

function! SvnCompare()
    let l:fileToCompare = @%
    let l:fileName = expand('%:t')
    diffthis
    execute "vnew from_repo--" . l:fileName
    call s:setupScratchBuffer()
    execute "silent %! svn cat --non-interactive " . l:fileToCompare
    diffthis
endfunction

function! SvnRevert(toRevert, showOutput)
    call inputsave()
    let confirmation = input('Are you sure you want to revert ' . a:toRevert . '? (y|n) ')
    call inputrestore()
    if confirmation == 'y' || confirmation == 'Y'
        if a:showOutput
            let prefix = ''
        else
            let prefix = 'silent '
        endif
        execute prefix . "!svn revert " . a:toRevert
    endif
endfunction

function! SvnAdd(toAdd, showOutput)
    if a:showOutput
        let prefix = ''
    else
        let prefix = 'silent '
    endif
    execute prefix . "!svn add " . a:toAdd
endfunction
