##############################################################
# git.sh
# Little git helpers.
##############################################################

function git-go() {
	# goto root directory of the .git project
	if [ -d ".git" ]; then
		echo ".git already exists in the current working-directory."
		return 1
	fi
	local PARENT=".."
	local SEARCH="$PARENT"
	while true; do
		if [ -d "$SEARCH/.git" ]; then
			echo "$PWD"
			cd $SEARCH
			return 0
		elif [ "$(realpath $SEARCH)" = "/" ]; then
			echo "No parent .git project."
			return 1
		else
			SEARCH="$PARENT/$SEARCH"
		fi
	done
}

function git-scrub() {
	# scrub (delete) merged branches
	local CURRENT_BRANCH=$(git branch --show-current)
	if [ $CURRENT_BRANCH != "main" && $CURRENT_BRANCH != "master" ]; then
		echo "Must be on main or master branch to git-scrub!"
		return 1
	fi
	for branch in $(git branch --merged HEAD|grep -vw $CURRENT_BRANCH); do
		git branch -d $branch
	done
}
