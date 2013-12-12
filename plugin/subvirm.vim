command! SvnStatus call s:svnStatusInit()
command! SvnDiff call DoSvnCompare()
"TODO add an annotate feature
"TODO a a syntax file for the status screen
"TODO add a revert feature (with are you sure)

function! s:svnStatusInit()
    botright 50vnew
    nmap <buffer> q :q!<cr>
    call s:svnStatus()
    setlocal nowrap
    nmap <buffer> a :call SvnAddAndRefresh()<CR>
    nmap <buffer> c :call SvnCompareFromStatus()<CR>
    nmap <buffer> r :call RefreshSvnStatus()<CR>
    "TODO validate current line is a file
    nmap <buffer> f :execute "tabe " . eval("strpart(getline('.'), 8)")<CR> 
endfunction

function! SvnAddAndRefresh()
    "TODO validate current line is a file
    execute "silent !svn add " . eval("strpart(getline('.'), 8)")
    call RefreshSvnStatus()
endfunction

function! RefreshSvnStatus()
    silent %! svn st
    normal ggO---------------------------------------------
    normal oq - to quit
    normal oa - to add to SVN
    normal oc - to compare with latest
    normal of - open file
    normal or - refresh view
    normal o---------------------------------------------
    normal o
endfunction

function! SvnCompareFromStatus()
    "TODO validate current line is a file
    execute "tabe " . eval("strpart(getline('.'), 8)")
    call SvnCompare()
endfunction

function! SvnCompare()
    let l:fileToCompare = @%
    let l:tempFile = $TEMP . "\\from_repo_" . expand('%:t')
    execute "silent !svn cat --non-interactive " . l:fileToCompare . " > " . l:tempFile 
    execute "vert diffsplit " .  l:tempFile
endfunction
