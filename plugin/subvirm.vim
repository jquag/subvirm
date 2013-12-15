command! SvnStatus call SvnStatus()
command! SvnDiff call SvnCompare()
command! -nargs=1 SvnCommit !svn commit -m <args>
command! SvnRevert call SvnRevert(@%)
command! SvnAdd call SvnAdd(@%)
command! SvnAnnotate call SvnAnnotate(@%, line("."))

function! s:setupScratchBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    nmap <buffer> q :q<CR>
endfunction

function! SvnAnnotate(toAnnotate, lineNbr)
    execute "tabe " . a:toAnnotate . "--annotated"  
    call s:setupScratchBuffer()
    setlocal syntax=subvirm_annotated
    execute "silent %! svn ann " . a:toAnnotate 
    execute ":" . a:lineNbr
    nmap <buffer> = :call SvnLogFromAnnotate()<CR>
endfunction

function! SvnLogFromAnnotate()
    let revision = matchstr(getline("."), '\d\+')
    let theFile = @%[0:len(@%)-len(" --annotated")]
    execute "5sp " . theFile . "@" . revision . "--log"
    call s:setupScratchBuffer()
    setlocal wfh
    execute "silent %! svn log " . theFile . "@" . revision . " -l 1"
endfunction

function! SvnStatus()
    botright 50vnew SvnStatus
    call s:setupScratchBuffer()
    setlocal nowrap
    setlocal noautoindent
    set syntax=subvirm_status
    call SvnRefreshStatus(0)
    nmap <buffer> + :call SvnScheduleFromStatus()<CR>
    nmap <buffer> = :call SvnCompareFromStatus()<CR>
    nmap <buffer> r :call SvnRefreshStatus(line('.'))<CR>
    nmap <buffer> <CR> :call SvnOpenFileFromStatus()<CR>
    nmap <buffer> - :call SvnRevertFromStatus()<CR>
    nmap <buffer> I :call SvnIgnoreFromStatus()<CR>
endfunction

function! SvnIgnoreFromStatus()
    if has("gui_running")
        if has("mac")
            let cmd = 'mvim'
        else
            let cmd = 'gvim'
        endif
    else
        let cmd = 'vim'
    endif

    if getline('.')[0:0] == '?'
        let filePath = eval("strpart(getline('.'), 8)")
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
        call SvnRefreshStatus(line('.'))
    else
        echo 'nothing to ignore'
    endif
endfunction

function! SvnRefreshStatus(lineNbr)
    silent %! svn st
    normal ggO -------------------------------------------
    normal o| 
    normal o| q     quit
    normal o| r     refresh view
    normal o| <CR>  open file in a new tab
    normal o| =     compare file with latest
    normal o| +     schedule file for addition/deletion
    normal o| -     revert file
    normal o| I     ignore file
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
        call SvnAdd(eval("strpart(getline('.'), 8)"))
        call SvnRefreshStatus(line('.'))
    elseif getline('.')[0:0] == '!'
        execute "silent !svn delete " . eval("strpart(getline('.'), 8)")
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

function! SvnRevertFromStatus()
    let l = getline('.')[0:0] 
    if l == 'M' || l == 'A' || l == 'D'
        let toRevert = strpart(getline('.'), 8)
        call SvnRevert(toRevert)
        call SvnRefreshStatus(line('.'))
    else
        echo "nothing to revert"
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

function! SvnRevert(toRevert)
    call inputsave()
    let confirmation = input('Are you sure you want to revert ' . a:toRevert . '? (y|n) ')
    call inputrestore()
    if confirmation == 'y' || confirmation == 'Y'
        execute "silent !svn revert " . a:toRevert
        redraw!
    endif
endfunction

function! SvnAdd(toAdd)
    execute "silent !svn add " . a:toAdd
    redraw!
endfunction
