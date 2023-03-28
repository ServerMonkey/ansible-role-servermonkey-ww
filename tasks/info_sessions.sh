#!/bin/sh
#info: Show logged in users (cygwin comp)

# windows
if [ -n "$(command -v systeminfo)" ]; then
	echo "Users Cygwin:"
	who | awk '{$1=$1;print}'

	echo "Users Windows:"
	# find all user accounts
	ALL_USERS=$(net user | awk '{$1=$1;print}' | sed '/^ *$/d')
	# verify
	if ! echo "$ALL_USERS" | grep -q "completed successfully"; then
		echo "Failed command 'net user'"
		exit 1
	fi
	ALL_USERS_LIST=$(echo "$ALL_USERS" |
		sed "/^User accounts for.*/d" |
		sed "/^-----.*/d" |
		sed "/^The command completed.*/d" |
		tr "\n" " " | sort)

	# find desktop sessions by comparing tasks for each user
	TASKS=$(tasklist /NH /V)
	TASKS_FORMATTED=$(echo "$TASKS" | awk '{$1=$1;print}')

	for i in $ALL_USERS_LIST; do
		USER_TASKS=$(echo "$TASKS_FORMATTED" | grep "\\$i ")
		# desktop session
		if echo "$USER_TASKS" | grep -q "explorer.exe"; then
			echo "Desktop : $i"
		# bash session
		elif echo "$USER_TASKS" | grep -q "bash.exe"; then
			echo "Bash    : $i"
		# some other session
		elif [ -n "$USER_TASKS" ]; then
			echo "Terminal: $i"
		fi
	done

# posix
else
	who
fi
