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

Usage: $_FILE_NAME [-h|--help] [-u=|--user=<USER>]

Examples:
    $_FILE_NAME -u=ik1614
    $_FILE_NAME --user=am5113
    
Options:
    -h|--help
        Show this message.

    -u=|--user=<USER>
        Defines user name that will be added and granted access.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

### Default value for variables
user=""
# secondary groups to be added for a user
# 'csp-mandic': to grant access to ssh and shared files
# 'docker': to use docker without sudo privileges
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
new_user_home="/hdd/csp-mandic/${user}"
declare -a DIR_LIST=("/hdd/log/${user}"
                     "/hdd/tmp/${user}"
                     )

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

### Get entries from Imperial LDAP for the specified user
GETENTPASSWD="$(getent passwd ${user})"
if [ $? -ne 0 ]; then
    echo "ERROR: Could not 'getent' for [${user}]." >&2
    exit 1
fi
USER_UID="$(echo ${GETENTPASSWD} | awk -F: '{ print $3 }')"
USER_GID="$(echo ${GETENTPASSWD} | awk -F: '{ print $4 }')"
user_home="$(echo ${GETENTPASSWD} | awk -F: '{ print $6 }')"

### Check if user has already been granted access (If it is presented in the local /etc/passwd)
if grep -q "${user}:[x*]:${USER_UID}:${USER_GID}:.*:${new_user_home}:" /etc/passwd; then
    echo "INFO: [${user}] have already been added to local '/etc/passwd'."
else
    ### Check that default home directory matches expected pattern and can be successfully changed vid 'sed'
    # By default, it is specified by Imperial LDAP as '/home/__user__')
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
fi


### Add secondary groups fro user
for secondary_group in "${GROUP_LIST[@]}"
do
    if groups $user | grep &>/dev/null "\b${secondary_group}\b"; then
        echo "INFO: [$user] is already a member of group [$secondary_group]."
    else
        echo "INFO: Adding [$secondary_group] to the list of secondary groups for [$user]."
        usermod -a -G $secondary_group $user
    fi
done

### Create additional directories which can not be specified in /etc/skel
for user_dir in "${DIR_LIST[@]}"
do
    if [ ! -d "$user_dir" ]; then
        echo "INFO: Creating additional directories for user convenience."
        echo -e "\t $user_dir"
        mkdir $user_dir
        chown $USER_UID:$USER_GID $user_dir
    fi
done

### Register as allowed user and define ports to be exposed (allowed to use)
if grep -q "${user}," ${ALLOWED_USERS_INFO}; then
    echo "INFO: [${user}] is already present in the list of allowed users with additional information:"
    temp=`grep "${user}," ${ALLOWED_USERS_INFO}`
    echo -e "\t $temp"
    exit 0
else
    echo "INFO: Registering additional info about [${user}]."
    jl_port_last=`tail -1 $ALLOWED_USERS_INFO | awk -F, '{ print $2 }'`
    if [ -z ${jl_port_last} ]; then
        jl_port="9000"
        echo "WARNING: Standard ports for [$user] have not been configured correctly."
    else
        jl_port=$(( $jl_port_last + 10 ))
    fi
    jn_port=$(( $jl_port + 1 ))
    tf_board_port=$(( $jn_port + 1 ))
    additional_user_info="${user},${jl_port},${jn_port},${tf_board_port}"
    echo -e "\t `head -n 1 $ALLOWED_USERS_INFO`"
    echo -e "\t $additional_user_info"
    echo $additional_user_info >> $ALLOWED_USERS_INFO
fi


### Initialise Trash bin for a user
# TODO: Initialise Trash bin for a user

