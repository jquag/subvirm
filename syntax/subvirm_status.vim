syntax match stRule /-\{5,}/
syntax match stVertRule /^|/ contained
syntax match stAction / \(q\|r\|<CR>\|=\|+\|-\) / contained
syntax region stActionLine start=/^|/ end=/$/ contains=stAction,stVertRule
syntax match stChangeStatus /^\(M\|A\|D\)/
syntax match stScheduleStatus /^\(?\|!\)/

hi link stRule Comment
hi link stVertRule Comment
hi link stAction Identifier
hi link stChangeStatus Operator
hi link stScheduleStatus Constant
