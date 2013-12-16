syntax match stRule /-\{5,}/
syntax match stDelim /|/ contained
syntax match stRevision /r\d\+/ contained
syntax region stInfoLine start=/^r\d\+/ end=/$/ contains=stDelim,stRevision

hi link stInfoLine Character
hi link stRule Comment
hi link stDelim Comment
hi link stRevision Identifier
