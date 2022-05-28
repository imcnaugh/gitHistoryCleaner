#!/bin/bash
set -eEo pipefail

DEFAULT_BRANCH_TO_REDUCE="master"
INITIAL_COMMIT_MESSAGE="Initial commit, git history before this point has been removed."
REPOSITORY_DIR="repositoryToClean"

REPOSITORY_URL=${1}
CREATE_BACKUP=false

OPTIND=2
while getopts "kb:" opt; do
			case $opt in
				k) CREATE_BACKUP=true;;
				b) BRANCHS_TO_REDUCE+=("$OPTARG");;
			esac
done

#if no branchs are given, use the default branch to reduce
if [ -z $BRANCHS_TO_REDUCE ]; then
	BRANCHS_TO_REDUCE=$DEFAULT_BRANCH_TO_REDUCE
fi

#clone the repo
git clone $REPOSITORY_URL $REPOSITORY_DIR
cd $REPOSITORY_DIR

#create a backup of the repository
if [ $CREATE_BACKUP = true ]; then
	BASE_NAME=$(basename -s .git `git config --get remote.origin.url`)
	cd ..
	git clone $REPOSITORY_URL "${BASE_NAME}_old"
	cd $REPOSITORY_DIR
fi

#clean up if anything fails
trap "cd ..; rm -rf $REPOSITORY_DIR" ERR

reduce_branch(){
	TEMP_BRANCH_POSTFIX="_temp_branch_for_cleaning"

	git checkout $1

	#make a temp branch
	git checkout --orphan "${1}${TEMP_BRANCH_POSTFIX}"

	#commit the new original commit
	git commit -am "${INITIAL_COMMIT_MESSAGE}"

	#remove original branch and rename current branch
	git branch -D $1
	git branch -m $1
}

#for each branch to keep, reduce it down to a single commit
for BRANCH in "${BRANCHS_TO_REDUCE[@]}"
do
	reduce_branch $BRANCH
done

#are you sure check
BRANCHES="${BRANCHS_TO_REDUCE[@]}"
read -p "Are you sure you want force push '$BRANCHES'. this will overwrite the commit history, and delete all other branches? [Y/N]: " RESPONSE
if [ "$RESPONSE" != "Y" ]
then
	echo "'Y' was not selected, exiting the script, the remote repo will be left as is"
	cd ../
	rm -rf $REPOSITORY_DIR
	exit 0
fi

#removes all tags
for t in $(git ls-remote -t --refs | tr '\t' '|' | tr '\n' ' ')
do
	TAG=${t:51}
	echo "removing tag ${TAG}"
	git push origin --delete $TAG
done

#removes all branches except master
for b in $(git branch -r)
do
	BRANCH_NAME=${b#"origin/"}
	REDUCED_BRANCH=false
	for BRANCH in "${BRANCHS_TO_REDUCE[@]}"
	do
		if [ "$BRANCH" == "$BRANCH_NAME" ]
		then
			REDUCED_BRANCH=true
		fi
	done

	if [[ $REDUCED_BRANCH == false && $BRANCH_NAME != "HEAD" && $BRANCH_NAME != "->" ]]
	then
		echo "removing branch ${BRANCH_NAME}"
		git push origin --delete $BRANCH_NAME
	fi
done

#overwrite master on remote with new, cleaned master
for BRANCH in "${BRANCHS_TO_REDUCE[@]}"
do
	git push -f origin $BRANCH
done

#clean up dir
cd ../
rm -rf $REPOSITORY_DIR

echo "Repository history has been erasesd, all users will now have to pull force on ${MASTER_BRANCH} or clone the repository again"
