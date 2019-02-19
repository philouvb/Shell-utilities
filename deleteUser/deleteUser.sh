#!/bin/bash

############################################################
### Define Functions                                     ###
############################################################
function get_answer {

UNSET ANSWER
ASK_COUNT=0

while [ -z "$ANSWER" ]
do
    ASK_COUNT=$[ $ASK_COUNT] + 1 ]

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
