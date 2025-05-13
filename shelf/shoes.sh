##############################################################
# shoes.sh
# Manages a common token file and cluster login files. Source
# the token with -t, edit it with -e. Name a cluster to source
# a matching cluster file. If multiple cluster files match,
# falls-back to searching for the given name. You can force
# this search-behaviour with -s if you don't want to login.
# When naming a cluster, use -e and -c to create a new cluster
# file with the given name.
##############################################################

function shoes() {
	local SHOES_PATH="$HOME/.local/share/shoes"
	local ACTION=""
	local CLUSTER=""
	mkdir -p $SHOES_PATH{,/cluster}
	case $1 in
	-c|--create)
		ACTION="create"
		CLUSTER="$2"
		;;
	-e|--edit)
		ACTION="edit"
		CLUSTER="$2"
		;;
	-h|--help)
		ACTION="help"
		;;
	-s|--search)
		ACTION="search"
		CLUSTER="$2"
		;;
	-t|--token)
		ACTION="token"
		CLUSTER="$2"
		;;
	*)
		ACTION="login"
		CLUSTER="$1"
		;;
	esac
	case $ACTION in
	help)
		echo "Usage: shoes [OPTIONS] <CLUSTER>"
		echo "  Login to a cluster with a saved token. If no single cluster-file"
		echo "  matches the given name, list all matches. Non-login action are"
		echo "  triggered via options:"
		echo 
		echo "  -c, --create     Create a cluster-file with the given name."
		echo "  -e, --edit       Edit the token (or cluster-file if given.)"
		echo "  -h, --help       Display this help message."
		echo "  -r, --rename     Rename a cluster file."
		echo "  -s, --search     List matching cluster files."
		echo "  -t, --token      Source the token."
		return 0
		;;
	create)
		if [ -z "$CLUSTER" ]; then
			>&2 echo "Name a cluster to create."
			return 1
		fi
		if [ -e "$SHOES_PATH/cluster/$CLUSTER.sh" ]; then
			>&2 echo "Cluster file already exists at $SHOES_PATH/cluster/$CLUSTER.sh"
			return 1
		fi
		>&2 echo "Editing cluster file at $SHOES_PATH/cluster/$CLUSTER.sh"
		vi "$SHOES_PATH/cluster/$CLUSTER.sh"
		return $?
		;;
	edit)
		if [ -n "$CLUSTER" ]; then
			if [ -e "$SHOES_PATH/cluster/$CLUSTER.sh" ]; then
				>&2 echo "Editing cluster file at $SHOES_PATH/cluster/$CLUSTER.sh"
				vi "$SHOES_PATH/cluster/$CLUSTER.sh"
				return $?
			fi
			>&2 echo "Cluster file does not exist at $SHOES_PATH/cluster/$CLUSTER.sh"
			return 1
		fi
		>&2 echo -n "Backing up token: "
		cp -v "$SHOES_PATH/_token.txt" "$SHOES_PATH/_token.txt.bak"
		>&2 echo "Editing token at $SHOES_PATH/_token.txt"
		>&2 echo "If you want to source the token, run:"
		>&2 echo "  shoes -t"
		vi "$SHOES_PATH/_token.txt"
		return $?
		;;
	token)
		if [ -n "$CLUSTER" ]; then
			>&2 echo "Error: Do not specify a cluster when sourcing the token."
			return 1
		fi
		>&2 echo "Sourcing token from $SHOES_PATH/_token.txt"
		export VAULT_TOKEN=$(cat "$SHOES_PATH/_token.txt")
		return 0
		;;
	login)
		if [ -z "$CLUSTER" ]; then
			>&2 echo "Name a cluster to search for."
			return 1
		fi
		if [ -e "$SHOES_PATH/cluster/$CLUSTER.sh" ]; then
			>&2 echo "Sourcing cluster file at $SHOES_PATH/cluster/$CLUSTER.sh"
			source "$SHOES_PATH/cluster/$CLUSTER.sh"
			return $?
		fi
		;& # fall-through if no cluster file matches exactly
	search)
		if [ -z "$CLUSTER" ]; then
			CLUSTER=".*"
		fi
		local CLUSTER_LIST="$(ls $SHOES_PATH/cluster|grep -v ^_|awk -F. '{print $1}'|sort)"
		local MATCHES=$(grep $CLUSTER <<< $CLUSTER_LIST)
		local LENGTH=$(wc -l <<< $MATCHES|xargs)
		if [ "$MATCHES" = "" ]; then
			>&2 echo "Found 0 clusters matching \"$CLUSTER\""
			return 1
		elif [ "$LENGTH" -gt 1 ]; then
			ACTION="search"
		fi
		if [ "$ACTION" = "search" ]; then
			>&2 echo "Found $LENGTH matching clusters:"
			sed 's/^/  /' <<< $MATCHES|grep --color $CLUSTER
			return 0
		else
			>&2 echo "Sourcing cluster file at $SHOES_PATH/cluster/$MATCHES.sh"
			source "$SHOES_PATH/cluster/$MATCHES.sh"
		fi
		;;
	esac
}
