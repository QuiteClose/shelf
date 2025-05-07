##############################################################
# timestamp.sh
# Records lines of text along with a timestamp. Use with a -
# to add a note to the last timestamp, or with --all to see
# with notes.
##############################################################

function ts() {
	local STAMP="$(date -u '+%y%m%d.%H%MZ')"
	local TXT="timestamps.txt"
	if [ -z "$1" ]; then
		if [ -e $TXT ]; then
			grep --color '^\d\S*' <(cat $TXT; echo "$STAMP <<< Current time.")
		else
			echo "$STAMP <<< Current time."|grep --color '^\S*' 
		fi
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

function tsl() {
	ts|sed 's/Z/+0000/'|while read line; do
		local GIVEN_STAMP="$(awk '{print $1}' <<< $line)"
		local CONVERTED_STAMP="$(date -j -f '%y%m%d.%H%M%z' $GIVEN_STAMP '+%y%m%d.%H%M%z')"
		sed "s/$GIVEN_STAMP/$CONVERTED_STAMP/" <<< $line
	done|grep --color '^\S*'
}

