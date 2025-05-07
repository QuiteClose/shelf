##############################################################
# timestamp.sh
# Records lines of text along with a timestamp. Use with a -
# to add a note to the last timestamp, or with --all to see
# with notes.
##############################################################

function ts() {
	local STAMP="$(date -u '+%y%m%d-%H%MZ')"
	local TXT="timestamps.txt"
	if [ -z "$1" ]; then
		grep --color '^\d\S*' <(cat $TXT; echo "$STAMP <<< Current time.")
	elif [[ "$@" = "--help" ]]; then
		echo "Usage: ts [OPTIONS] [MESSAGE]"
		echo "Record a message to timestamps.txt along with a timestamp."
		echo 
		echo "  -                Add a note to the last timestamp."
		echo "  --all            Show all timestamps with notes."
		echo
	elif [[ "$@" = "--all" ]]; then
		grep --color '^\S*' <(cat $TXT; echo "$STAMP <<< Current time.")
	elif [[ "$@" = "-" ]]; then
		grep '^\d' $TXT|tail -n1|grep --color '^\S*'
		echo "Enter notes:"|grep --color '.*'
		sed 's/^/  /' >> $TXT
		echo "Use \"ts --all\" to see notes."|grep --color '.*'
	else
		echo "$STAMP $@"|tee -a $TXT|grep --color '^\S*'
	fi
}
