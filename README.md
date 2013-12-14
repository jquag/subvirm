subvirm
=======

Simple Subversion plugin for Vim

## Commands
#### :SvnStatus
Opens a split window with the output of 'svn status'. In addition, the buffer offers some useful context specific actions.

#### :SvnDiff
Retrieves the latest content of the current file from the repository and displays a Vim diff from the working copy.

#### :SvnCommit &lt;message&gt;
Does a commit with the provided message.

#### :SvnRevert
Does a revert on the current file. This command presents an 'are you sure' confirmation.

#### :SvnAdd
Does and add for the current file.
