#!/bin/bash

############################################################
###    ____       _      _         _   _                 ###
###   |  _ \  ___| | ___| |_ ___  | | | |___  ___ _ __   ###
###   | | | |/ _ \ |/ _ \ __/ _ \ | | | / __|/ _ \ '__|  ###
###   | |_| |  __/ |  __/ ||  __/ | |_| \__ \  __/ |     ###
###   |____/ \___|_|\___|\__\___|  \___/|___/\___|_|     ###
###                                                      ###
############################################################

############################################################
### Define Functions                                     ###
############################################################
function get_answer {

unset ANSWER
ASK_COUNT=0

while [ -z "$ANSWER" ]
do
    ASK_COUNT=$[ $ASK_COUNT + 1 ]

    case $ASK_COUNT in
    2)    
        echo
        echo "Please answer the question."
        echo
    ;;
    3)
        echo
        echo "One last try ...please answer the question."
        echo
    ;;
    4)
        echo
        echo "Since you refuse to answer the question..."
        echo

        exit
    esac

    echo

    if [ -n "$LINE2" ]
        then
            echo $LINE1
            echo -e $LINE2" \c"
        else
            echo -e $LINE1" \c"
    fi

# Allow 60 seconds to answer

    read -t 60 ANSWER

done

# Clean-up variable

unset LINE1
unset LINE2

}

function process_answer {

case $ANSWER in
y|Y|YES|yes|Yes|yEs|yeS|YEs|yES)
# if "yes" , do nothing.
;;
*)

    echo
    echo $EXIT_LINE1
    echo $EXIT_LINE2
    echo
    exit
;;
esac

# Clean-up
unset EXIT_LINE1
unset EXIT_LINE2
}
############################################################
### End of functions definitions                         ###
############################################################

############################################################
### Main Script                                          ###
############################################################

echo "Step #1 - Determine User Account to Delete "
echo
LINE1="Please enter the username of the user "
LINE2="account you wish to delete from the system:"

get_answer
USER_ACCOUNT=$ANSWER
# Double check
LINE1="Is $USER_ACCOUNT the user account "
LINE2="you wish to delete from the system? [y/n]"
get_answer

EXIT_LINE1="Because the account, $USER_ACCOUNT, is not "
EXIT_LINE2="the one you wish to delete, we are leaving the script..."

process_answer

# Check that USER_ACCOUNT is really an account on the system
USER_ACCOUNT_RECORD=$(cat /etc/passwd | grep -w $USER_ACCOUNT)

if [ "$?" -eq 1 ] # if the account is not found exit script
then
    echo >2
    echo "Account, $USER_ACCOUNT, not found. ">2
    echo "Leaving the script...">2
    exit 1
fi

echo
echo "I found this record:"
echo $USER_ACCOUNT_RECORD

# Confirm this is the correct account
LINE1="Is this the correct Account? [y/n]"
get_answer

# If answer is anything but "yes", exit script
EXIT_LINE1="Because the account, $USER_ACCOUNT, is not "
EXIT_LINE2="the one you wish to delete, we are leaving the script..."
process_answer

# Search for any running processes that belong to the User Account
ps -u $USER_ACCOUNT >/dev/null

case $? in
1)  # No processes running for this User Account.
    echo "There are no processes for this account currently running."
    echo
;;
0)  # Processes running for this User Account.
    echo "$USER_ACCOUNT has the following processes running: "
    echo
    ps -u $USER_ACCOUNT

    LINE1="Would you like me to kill the process(es)? [y/n]"
    get_answer
    
    case $ANSWER LINE2
      y|Y|YES|yes|Yes|yEs|yeS|YEs|yES ) # If answer is "yes",
                                        # kill user account processes
        echo
        echo "Killing off process(es)..."

        # List user processes
        COMMAND_1="ps -u $USER_ACCOUNT --no-heading"

        # Create command to kill processes
        COMMAND_3="xargs -d \\n /usr/bin/sudo /bin/kill -9"

        # Kill processes
        $COMMAND_1 | gawk '{print $1}' | COMMAND_3

        echo
        echo "Process(es) killed"
    ;;
  *)    # If answer anything but "yes", do not kill.
        echo
        echo "Will not kill the process(es)"
        echo
    ;;
    esac
;;
esac

##########################################################
### Create a report of all files owned by user account ###
##########################################################
echo
echo "Find files on system belonging to user USER_ACCOUNT"
echo
echo "Creating a report of all files owned by $USER_ACCOUNT."
echo
echo "It is recommended that you backup/archive these files,"
echo "and then do one of two things:"
echo "  1) Delete the files"
echo "  2) Change the files' ownership to a current user account."
echo
echo "Please wait. This may take a while..."

REPORT_DATE=$(date +%y%m%d)
REPORT_FILE=$USER_ACCOUNT"_Files_"$REPORT_DATE".rpt"

find / -user $USER_ACCOUNT > $REPORT_FILE 2>/dev/null

echo
echo "Report is complete."
echo "Name of report:     $REPORT_FILE"
echo "Location of report: $(pwd)"
echo

#########################################################
### Remove User Account                               ###
#########################################################
echo
echo "Remove user account"
echo

LINE1="Remove $USER_ACCOUNT's from the system? [y/n]"
get_answer

EXIT_LINE1="Since you do not wich to remove the user account,"
EXIT_LINE2="$USER_ACCOUNT at this time, exiting the script..."
process_answer

userdel $USER_ACCOUNT   # delete user account
echo
echo "User account, $USER_ACCOUNT, has been removed"
echo

exit
