execute 'syntax match svTerm /' . b:searchTerm . '/'
syntax match svAffectedPaths /Affected paths:/
syntax match svRevision /rev\.\d\+/ contained
syntax match svDelim /|/
syntax region svInfoLine start=/^rev\.\d\+/ end=/$/ contains=svTerm,svDelim,svRevision
syntax match svChangeStatus /^\(M\|A\|D\)\t/
syntax match svRule /-\{5,}/

hi link svInfoLine String
hi link svTerm IncSearch
hi link svAffectedPaths Constant
hi link svRevision Identifier
hi link svDelim Comment
hi link svChangeStatus Operator
hi link svRule Comment
