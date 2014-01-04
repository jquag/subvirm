subvirm
=======

Simple Subversion plugin for Vim

## Commands
#### :SvnStatus
Opens a split window with the output of <code>svn status</code>. In addition, the buffer offers some useful context specific actions which are explained inline.

#### :SvnDiff
Retrieves the latest content of the current file from the repository and displays a Vim diff from the working copy.

#### :SvnCommit MESSAGE
Does a commit with the provided message.

#### :SvnRevert
Does a revert on the current file. This command presents an 'are you sure' confirmation.

#### :SvnAdd
Does an add for the current file.

#### :SvnAnnotate
Opens a split with the output of <code>svn annotate</code> for the current file. In the new buffer you can see the log entry for the current line by pressing <code>CR</code>. Both the annotate buffer and log entry buffer can be closed by pressing <code>q</code>.

#### :SvnIgnore
Opens the <code>svn:ignore</code> editor for the directory of the current file. It will also append the name of the current file to the end of the list. If the intent is not to ignore the exact name of this file then be sure to change it before save and quit.

#### :SvnLog
Show the log for the current file. Within the log buffer you can press <code>CR</code> to bring up the diff for the revision for the revision represented by the current line.

#### :SvnSearchLog SEARCHTERM
Searches the log for the given SEARCHTERM and displays the result in a scratch buffer. Within this buffer you can press <code>D</code> or <code>c-d</code> on a path to bring up the diff. Or press <code>CR</code> or <code>c-CR</code> on the path to open the file. 

By default it will search the last 500 log entries. If you want to change this set the <code>g:subvrimSearchLimit</code> to whatever.

This command requires that vim be compiled with Ruby support.
