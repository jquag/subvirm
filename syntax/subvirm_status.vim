syntax match stRule /-\{5,}/
syntax match stVertRule /^|/ contained
syntax match stAction / \(q\|r\|<CR>\|=\|+\|-\|I\) / contained
syntax region stActionLine start=/^|/ end=/$/ contains=stAction,stVertRule
syntax match stChangeStatus /^\s*\(M\|A\|D\)/
syntax match stScheduleStatus /^\s*\(?\|!\)/

hi link stRule Comment
hi link stVertRule Comment
hi link stAction Identifier
hi link stChangeStatus Operator
hi link stScheduleStatus Constant
