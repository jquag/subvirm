subvirm
=======

Simple Subversion plugin for Vim

## Commands
#### :SvnStatus
Opens a split window with the output of <code>svn status</code>. In addition, the buffer offers some useful context specific actions which are explained inline.

#### :SvnDiff
Retrieves the latest content of the current file from the repository and displays a Vim diff from the working copy.

#### :SvnCommit &lt;message&gt;
Does a commit with the provided message.

#### :SvnRevert
Does a revert on the current file. This command presents an 'are you sure' confirmation.

#### :SvnAdd
Does an add for the current file.

#### :SvnAnnotate
Opens a new tab with the output of <code>svn annotate</code> for the current file. In the new buffer you can see the log entry for the current line by pressing <code>CR</code>. Both the annotate buffer and log entry buffer can be closed by pressing <code>q</code>.

#### :SvnIgnore
Opens the <code>svn:ignore</code> editor for the directory of the current file. It will also append the name of the current file to the end of the list. If the intent is not to ignore the exact name of this file then be sure to change it before save and quit.
