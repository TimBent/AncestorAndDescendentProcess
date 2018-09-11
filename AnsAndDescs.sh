#!/bin/bash

PID=$1 # sets script agruement to PID
	
function checkInt {
	num='^[0-9]+$' #regular expression for integer
	if ! [[ $PID =~ $num ]]; then
		echo Error: A PID must be an integer 
		exit 1; 
	fi
}

# prints pid, pname and network connections
function getNameandConnections {
	pname=`ps -p $1 -o comm= 2> /dev/null` # error is sent to null so it doesn't show in the terminal
	if [ $? -eq 0 ] ; then # if ps has an error the $? would be another number of exit code other than 0
		id="Process ID: "$1
		name="Process Name: "$pname
		network=`sudo netstat -ntap | grep ESTABLISHED | grep "\<"$1"/" | awk '{print $5}'` #gets the forgein IP address including port of an estbalished connection
		if [[ -z "${network// }" ]]; then # checks if $network is blank or contains an IP address
			printf "`echo $id`\n`echo $name`\n`echo Network Connection: ` `echo None`\n";
		else
			printf "`echo $id`\n`echo $name`\n`echo Network Connection: ` `echo $network`\n";
		fi
		echo " ";
	else # if ps name returned an error
		echo "None"
		echo " ";
	fi
}

function getAncestors {
	parentpid1=`ps -o ppid= -p $1 2> /dev/null`
	parentpid2=`ps -o ppid= -p $parentpid1 2> /dev/null`
	parentpid3=`ps -o ppid= -p $parentpid2 2> /dev/null` # errors are sent to null so they doesn't show in the terminal
	echo "Great-Grandparent" # titles for the block of info below
	getNameandConnections $parentpid3
	echo "	Grandparent"
	getNameandConnections $parentpid2 | sed 's/^/	/'
	echo "		Parent"
	getNameandConnections $parentpid1 | sed 's/^/		/' # sed is used to indent blocks of info on a PID 
}

function getDescendants {
	echo " "
	cid1=`pgrep -P $1`
	for c1 in $cid1; do
		echo "			Child"
		getNameandConnections $c1 | sed 's/^/			/';
		cid2=`pgrep -P $c1`
		for c2 in $cid2; do
			echo "				Grandchild"
			getNameandConnections $c2 | sed 's/^/				/';
		cid3=`pgrep -P $c2`
			for c3 in $cid3; do
				echo "					Great-Grandchild"
				getNameandConnections $c3 | sed 's/^/					/';
			done; 
		done
	done;
}

checkInt
getAncestors $PID
echo "			Selected Process"
getNameandConnections $PID | sed 's/^/			/'
getDescendants $PID
