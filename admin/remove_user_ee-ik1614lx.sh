#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    Withdraw access to 'ee-ik1614lx' for a specified user.
    This script should revert process of adding meta information about user.
    Requires 'sudo' privileges

Usage: $_FILE_NAME [-h|--help] [-u=|--user=<USER>]

Examples:
    $_FILE_NAME -u=ik1614
    $_FILE_NAME --user=am5113

Options:
    -h|--help
        Show this message.

    -u=|--user=<USER>
        Defines user name, whose access will be withdrawn.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

### Default value for variables
user=""
# secondary groups to be removed from a user
# 'csp-mandic': to revoke access to ssh and shared files
# 'docker': to revoke use of docker without sudo privileges
declare -a GROUP_LIST=("csp-mandic"
                       "docker"
                       )

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -u=*|--user=*)
            user="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

### Define new variables with respect to the parsed arguments


##############################################
###--------          MAIN          --------###
##############################################

source /hdd/csp-ict/ee-ik1614lx/variables.sh

if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root" >&2
   exit 1
fi

if [ -z $EE_IK1614LX_HOME ]; then
    echo "ERROR: Missing some required variables." >&2
    exit 1
fi
ALLOWED_USERS_INFO=$EE_IK1614LX_HOME/allowed_users_info.csv

### Check if user name has been specified
if [ -z "$user" ]; then
    echo "ERROR: User name has not been specified." >&2
    echo "Use '-h' to get help." >&2
    exit 1
fi

### Remove secondary groups from user.
echo "INFO: Removing secondary groups from [$user]."
for secondary_group in "${GROUP_LIST[@]}"
do
    if groups $user | grep &>/dev/null "\b${secondary_group}\b"; then
        gpasswd -d $user $secondary_group
    else
        echo "WARNING: [$user] is not a member of [$secondary_group]."
    fi
done

### Remove user the allowed users file. But keep it in the local '/etc/passwd'
echo "INFO: Removing [$user] from a list of allowed users and the corresponding information."
if ! grep -q "${user}," ${ALLOWED_USERS_INFO}; then
    echo "WARNING: [${user}] is not present in the list of allowed users with additional information."
else
    # TODO: remove only the first match (don't really need it since user name is unique and we delete line only if there is exact match)
    echo "INFO: Validate how file with users information will look after deleting [$user]."
    echo ""
    echo "=========== BEFORE DELETION ==========="
    cat $ALLOWED_USERS_INFO
    echo ""
    echo "=========== AFTER DELETION ============"
    # without '-i' option changes are outputted in STDERR
    sed "/\b\(${user}\)\b/d" $ALLOWED_USERS_INFO
    echo "======================================="
    echo ""
    printf "Is everything correct [y/n]? "
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    if echo "$answer" | grep -iq "^y" ;then
        # -i makes this change inplace
        sed -i "/\b\(${user}\)\b/d" $ALLOWED_USERS_INFO
    else
        echo "WARNING: Deletion has been canceled. Do it manually in:"
        echo -e "\t ${ALLOWED_USERS_INFO}"
    fi
fi


### Remove Trash bin associated with a user
# TODO: At the moment trash bin for a user is not created so there is nothing to remove

