#!/usr/bin/env bash
# TODO: Do not allow duplicates for the same user in local /etc/passwd.

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    Grants access to 'ee-ik1614lx' for a specified user.
    Requires 'sudo' privileges

Usage: $_FILE_NAME [-h|--help] [-u=|--user=<USER>] [-u=|--user-name=<USER>]

Examples:
    $_FILE_NAME -u=ik1614
    $_FILE_NAME --user=am5113
    
Options:
    -h|--help
        Show this message.

    -u=|--user=<USER>
        Defines user name that will be added and granted access.

    -g=|--group=<Group>
        Defines name of group that will be added to the list of
        secondary groups for the specified user.
        Default is 'csp-mandic'.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

### Default value for variables
user=""
group="csp-mandic"

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
        -g=*|--group=*)
            group="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

### Define new variables with respect to the parsed arguments
new_user_home="/hdd/csp-mandic/${user}"
user_log_dir="/hdd/log/${user}"
user_tmp_dir="/hdd/tmp/${user}"

##############################################
###--------          MAIN          --------###
##############################################

if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root" >&2
   exit 1
fi

### Check if user name has been specified
if [ -z "$user" ]; then
    echo "ERROR: User name has not been specified." >&2
    echo "Use '-h' to get help." >&2
    exit 1
fi

### Get entries from Imperial LDAP for the specified user
GETENTPASSWD="$(getent passwd ${user})"
if [ $? -ne 0 ]; then
    echo "ERROR: Could not 'getent' for [${user}]." >&2
    exit 1
fi
USER_UID="$(echo ${GETENTPASSWD} | awk -F: '{ print $3 }')"
USER_GID="$(echo ${GETENTPASSWD} | awk -F: '{ print $4 }')"
user_home="$(echo ${GETENTPASSWD} | awk -F: '{ print $6 }')"

### Check if user has already been granted access
if grep -q "${user}:[x*]:${USER_UID}:${USER_GID}:.*:${new_user_home}:" /etc/passwd; then
    echo "INFO: [${user}] have already been added to local '/etc/passwd'. Additional actions are not required."
    exit 0
fi


### Check if user has already been granted access
if [ $user_home != "/home/${user}" ]; then
    echo "ERROR: Unknown pattern for home directory for [${user}]." >&2
    echo "Expected [/home/${user}] but got [$user_home]." >&2
    exit 1
fi

### Add to local 'passwd' with changed home directory
# Change info about home directory (It will be created at the first login of the user)
user_passwd=`echo ${GETENTPASSWD} | sed "s|${user_home}|${new_user_home}|g"`

# Add to local 'passwd'
echo $user_passwd >> /etc/passwd

# Validate that it was successful
if grep -q "${user}:[x*]:${USER_UID}:${USER_GID}:.*:${new_user_home}:" /etc/passwd; then
    echo "INFO: [${user}] have been successfully added to local '/etc/passwd'."
else
    echo "ERROR: Failed to add [${user}] to local '/etc/passwd'" >&2
    exit 1
fi

### Add user to a group so he could ssh and access shared files # TODO: Do we need  to check whether user already in a group?
usermod -a -G $group $user


### Create associate directories for logs and temporary files
if [ ! -d "$user_log_dir" ]; then
    mkdir $user_log_dir
    chown $USER_UID:$USER_GID $user_log_dir
fi
if [ ! -d "$user_tmp_dir" ]; then
    mkdir $user_tmp_dir
    chown $USER_UID:$USER_GID $user_tmp_dir
fi


### Initialise Trash bin for a user
# TODO: Initialise Trash bin for a user
