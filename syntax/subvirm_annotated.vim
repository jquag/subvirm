syntax match stAnnotation /^\s\+\d\+\s\+\w\+\s\+/
syntax match stAnnotationNotCommitted /^\s\+-\s\+-/
hi link stAnnotation Ignore
hi link stAnnotationNotCommitted Todo
