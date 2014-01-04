" Author: John Quagliata

if !exists("g:SuperTabDefaultCompletionType")
    let g:subvirmSearchLimit = 500
endif

let s:path = expand('<sfile>:p:h')
execute "ruby load '" . s:path . '/subvirm.rb' . "'"


command! SvnStatus call SvnStatus()
command! SvnDiff call SvnCompare(-1)
command! -nargs=1 SvnCommit !svn commit -m <args>
command! SvnRevert call SvnRevert(@%, 1)
command! SvnAdd call SvnAdd(@%, 1)
command! SvnAnnotate call SvnAnnotate(@%, line("."))
command! SvnIgnore call SvnIgnore(@%)
command! SvnLog call SvnLog(@%, -1, 5)
command! -nargs=1 SvnSearchLog call SvnSearchLog(<f-args>)


function! SvnSearchLog(term)
    if !has('ruby')
        echo 'vim must be compiled with ruby support for this command'
        return
    endif

    execute 'botright vnew log_search_results'
    call s:setupScratchBuffer()
    let b:searchTerm = a:term
    setlocal syntax=subvirm_search_results
    nmap <buffer> D :call SvnCompareFromSearch(0)<CR>
    nmap <buffer> <c-d> :call SvnCompareFromSearch(1)<CR>
    nmap <buffer> <CR> :call SvnOpenFileFromScratch(0)<CR>
    nmap <buffer> <c-CR> :call SvnOpenFileFromScratch(1)<CR>
    normal i--------------------
    normal o

ruby <<EOF
search_term = VIM::evaluate('a:term')
limit = VIM::evaluate('g:subvirmSearchLimit')
results = search_svn_log(search_term, limit)
results.each {|line| $curbuf.append($curbuf.length, line)}
EOF

endfunction

function! SvnCompareFromSearch(newTab)
    if getline('.')[0:0] == 'M'
        let lineNbr = line('.')
        execute '?rev\.'
        let rev = matchstr(getline('.'), '\d\+')
        execute ':' . lineNbr

        let file = eval("strpart(getline('.'), 3)")

        if a:newTab
            execute "tabe " . file . '@' . rev
        else
            execute "botright sp " . file . '@' . rev
        end

        call s:setupScratchBuffer()
        execute "silent %! svn cat --non-interactive " . file . '@' . rev
        let b:file = file
        call SvnCompare(rev - 1)
    endif
endfunction

function! s:setupScratchBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    nmap <buffer> q :q<CR>
endfunction

function! SvnAnnotate(toAnnotate, lineNbr)
    set noscrollbind
    execute ":0"
    execute "30vs " . a:toAnnotate . "--annotated"
    setlocal nowrap
    au BufDelete <buffer> windo set noscb
    call s:setupScratchBuffer()
    setlocal syntax=subvirm_annotated
    execute "silent %! svn ann " . a:toAnnotate 
    setlocal scrollbind
    nmap <buffer> <CR> :call SvnLogFromAnnotate()<CR>
    wincmd p
    setlocal scrollbind
    execute ":" . a:lineNbr
endfunction

function! SvnDiffFromLog()
    if match(getline('.'), '^r\d\+ | ') == 0
        let rev = matchstr(getline('.'), '\d\+')
        let toDiff = b:theFile
        execute "vs doo"
        call s:setupScratchBuffer()
        set syntax=diff
        execute "silent %! svn diff -c " . rev . " " . toDiff
    endif
endfunction

function! SvnLog(toLog, rev, num)
    if a:num > 1
        let height = 15
    else
        let height = 5
    endif
    if a:rev == -1
        let revString = ''
    else
        let revString = '@' . a:rev
    endif

    execute "to " . height . "sp " . a:toLog . revString . a:rev . "--log"
    let b:theFile = a:toLog
    call s:setupScratchBuffer()
    set noscrollbind
    setlocal syntax=subvirm_log
    setlocal wfh
    nmap <buffer> <CR> :call SvnDiffFromLog()<CR>
    execute "silent %! svn log " . a:toLog . revString . " -l " . a:num
endfunction

function! SvnLogFromAnnotate()
    let revision = matchstr(getline("."), '\d\+')
    let theFile = @%[0:len(@%)-len(" --annotated")]
    call SvnLog(theFile, revision, 1)
endfunction

function! SvnStatus()
    botright 50vnew SvnStatus
    call s:setupScratchBuffer()
    setlocal syntax=subvirm_status
    setlocal nowrap
    setlocal noautoindent
    call SvnRefreshStatus(0)
    nmap <buffer> + :call SvnScheduleFromStatus()<CR>
    nmap <buffer> D :call SvnCompareFromStatus(0)<CR>
    nmap <buffer> <c-d> :call SvnCompareFromStatus(1)<CR>
    nmap <buffer> R :call SvnRefreshStatus(line('.'))<CR>
    nmap <buffer> <CR> :call SvnOpenFileFromScratch(0)<CR>
    nmap <buffer> <c-CR> :call SvnOpenFileFromScratch(1)<CR>
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

    if has("unix")
        let escapedQuote = '\"'
    else
        let escapedQuote = '""'
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
    execute "silent !svn propedit svn:ignore --editor-cmd \"" . cmd . " -f -c " . escapedQuote . 'normal Go' . fileName . escapedQuote . "\" " . folderName 
    redraw!
endfunction

function! SvnRefreshStatus(lineNbr)
    silent %! svn st
    normal ggO -------------------------------------------
    normal o| 
    normal o| q     quit
    normal o| R     refresh view
    normal o| <CR>  open in a new tab (ctrl for new tab)
    normal o| D     compare with latest (ctrl for new tab)
    normal o| +     schedule file for addition/deletion
    normal o| -     revert or ignore file
    normal o| 
    normal o ---------------------------------------------
    normal o
    execute ':' . a:lineNbr
endfunction

function! SvnOpenFileFromScratch(newTab)
    let l = getline('.')[0:0]
    if l == '?' || l == 'M' || l == 'A'
        let l:file = strpart(getline('.'), matchend(getline('.'), '[M?A]\s\+')) 
        if a:newTab
            execute "tabe " . l:file
        else
            execute "botright sp " . l:file
        endif
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


function! SvnCompareFromStatus(newTab)
    if getline('.')[0:0] == 'M'
        let l:file = eval("strpart(getline('.'), 8)")
        if a:newTab
            execute "tabe " .  l:file
        else
            execute "botright sp " . l:file
        endif
        let b:file = l:file
        call SvnCompare(-1)
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

function! SvnCompare(rev)
    if exists('b:file')
        let l:fileToCompare = b:file
    else
        let l:fileToCompare = expand('%@')
    endif

    if a:rev == -1
        let l:rev = ''
        let l:revString = '@latest'
    else
        let l:rev = '@' . a:rev
        let l:revString = '@' . a:rev
    endif

    diffthis
    execute "vnew " . l:fileToCompare . l:revString
    call s:setupScratchBuffer()
    execute "silent %! svn cat --non-interactive " . l:fileToCompare . l:rev
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
