syntax match stAnnContent /.*/
syntax match stAnnRevision /^\s\+\d\+/ contained
syntax match stAnnotation /^\s\+\d\+\s\+\w\+\s\+/ contains=stAnnRevision
syntax match stAnnNotCommitted /\s\+\-\s\+-/

hi link stAnnContent Ignore
hi link stAnnotation Operator
hi link stAnnRevision Identifier
hi link stAnnNotCommitted Normal
