#This Excuable file will provide the following information when given a Process ID
#ID, Network connections, up to 3 Parent processes and 3 generations of Child processes

PID=$@

function numCheck {
        number='^[1-9]+$'
        if ! [[ $PID =~ $number ]]; then
                echo "Error: An integer value is required. Run the ps comman to check the PID"
                exit -1
        fi
}

#This function gets th ename and network connection for ht epid specified by the user
function getNameandConn {
        PRSSN=`ps -p $1 -o cmd= 2> /dev/null` #select only the command name of the process, sends error to a null are so that it doesn't clutter the terminal

        if [ $? -eq '0' ] ; #Using the $? gets the value of the exit cod. Anything other than zero will return PROCESS NOT RUNNING
        then
        echo "PID: " $1 "COMMAND: " $PRSSN
        NTS=`sudo netstat -natp | grep ESTABLISHED | grep "\<"$PID"/" | awk '{print $5}'`
                if [[ $NTS -eq '0' ]] #check that the value of the Network ID is zero
                        then
                        echo "NO NETWORK CONNECTIONS FOUND!"
                        else
                        echo "NETWORK CONNECTION :" $NTS
                fi
        else  #if there is no process name returned
                echo "POCESS IS NOT RUNNING"
        fi

}

#this function handles the retrieval of the parent, Grand Parent and Great Grand Parent IDs
function getAncestors {

        PP=`ps -p $1 -o ppid= 2> /dev/null`
        GP=`ps -p $PP -o ppid= 2> /dev/null`
        GGP=`ps -p $GP -o ppid= 2> /dev/null`

        echo "PPID: ->" $PP
        getNameandConn $PP
        echo "GPPID: ->" $GP
        getNameandConn $GP
        echo "GGPID: ->" $GGP
        getNameandConn $GGP

}
#this function recursively collates the values of the Child process ids
function getChildren {
        CP=`pgrep -P $1`
        for i in $CP
        do
        echo " "
                if [[ $i -eq '0' ]]
                then
                        echo "There are no child processes for " $1
                        exit
                else
                        echo "CPID: ->" $i
                        getNameandConn $i
                GCP=`pgrep -P $i`
        fi
				for j in $GCP
                do
                echo " "
                        if [[ $j -eq '0' ]]
                        then
                                echo "PID: " $i "HAS NO CHILD PROCESSES"
                                                                exit -1
                        else
                                echo "GCPID:->" $j
                                getNameandConn $j
                        GGCP=`pgrep -P $j`
                fi
                        for k in $GGCP
                        do
                        echo " "
                                if [[ $k -eq '0' ]]
                                then
                                        echo "PID: " $j "HAS NO CHILD PROCESSES"
                                else
                                echo "GGCPID:->" $k
                                getNameandConn $k
                        fi
                        done
                done
        done
}

numCheck
getNameandConn $PID
getAncestors $PID
getChildren $PID
