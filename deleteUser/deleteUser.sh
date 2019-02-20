#!/bin/bash

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

