"TODO add an annotate feature
"TODO remember line after refreshing status

command! SvnStatus call SvnStatus()
command! SvnDiff call SvnCompare()
command! -nargs=1 SvnCommit !svn commit -m <args>
command! SvnRevert call SvnRevert(@%)
command! SvnAdd call SvnAdd(@%)

function! SvnStatus()
    botright 50vnew SvnStatus
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nowrap
    setlocal noautoindent
    set syntax=subvirm_status
    nmap <buffer> q :q!<cr>
    call SvnRefreshStatus()
    nmap <buffer> + :call SvnScheduleFromStatus()<CR>
    nmap <buffer> = :call SvnCompareFromStatus()<CR>
    nmap <buffer> r :call SvnRefreshStatus()<CR>
    nmap <buffer> <CR> :call SvnOpenFileFromStatus()<CR>
    nmap <buffer> - :call SvnRevertFromStatus()<CR>
endfunction

function! SvnRefreshStatus()
    silent %! svn st
    normal ggO -------------------------------------------
    normal o| 
    normal o| q     quit
    normal o| r     refresh view
    normal o| <CR>  open file in a new tab
    normal o| =     compare file with latest
    normal o| +     schedule file for addition/deletion
    normal o| -     revert file
    normal o| 
    normal o ---------------------------------------------
    normal o
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
        call SvnRefreshStatus()
    elseif getline('.')[0:0] == '!'
        execute "silent !svn delete " . eval("strpart(getline('.'), 8)")
        call SvnRefreshStatus()
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
        call SvnRefreshStatus()
    else
        echo "nothing to revert"
    endif
endfunction

function! SvnCompare()
    let l:fileToCompare = @%
    let l:fileName = expand('%:t')
    diffthis
    execute "vnew from_repo--" . l:fileName
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    execute "silent %! svn cat --non-interactive " . l:fileToCompare
    diffthis
endfunction

function! SvnRevert(toRevert)
    call inputsave()
    let confirmation = input('Are you sure you want to revert ' . a:toRevert . '? (y|n) ')
    call inputrestore()
    if confirmation == 'y' || confirmation == 'Y'
        execute "!svn revert " . a:toRevert
    endif
endfunction

function! SvnAdd(toAdd)
    execute "silent !svn add " . a:toAdd
endfunction
