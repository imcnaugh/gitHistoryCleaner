holy crap this script is scary,

# Git History Cleaner

This script will remove a git repositorys entire commit log, along with any branches and tags.

NOTHING WILL BE LEFT EXCEPT ONE COMMIT ON MASTER CONTAINING THE ENTIRE PROJECT.

I cannot put it any more gently. this script is harmful...

## Usage

to use this script, be sure you have access to the repository you no longer want a git history. By this I mean you should have an ssh key on your machine that pairs with the repository. get the ssh url to the repository, just like you were going to clone it. and use it as an argument to this script.

``` ./cleanGitHistory.sh ssh://git@git.uptake.com:7999/~imcnaughton/githistoryremover.git ```

this script assumes the master branch of your repository is 'master' if this is not the case you may add a -b flag folowed by the the name of your master branch.

If you wish to save multiple branches. you can added multiple -b flags as in the following

``` ./cleanGitHistory.sh ssh://git@git.uptake.com:7999/~imcnaughton/githistoryremover.git -b master -b secondBranch ```

This will save both the master and secondBranch, but reduce both down a single commit containing the branches contents.

If you wish to keep a backup of the repo, you can add a `-k` flag (keep a copy), this will clone the repository and save it in your file path before any breaking changes are pushed to the remote.

## Going forward

To use this repository localy, you must reset your local git to match the new remote, using the following will remove your local git history, and match your local repository with the remote. 

```git reset --hard origin/master```