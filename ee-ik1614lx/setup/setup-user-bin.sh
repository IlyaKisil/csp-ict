#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

set -e

_FILE_NAME=`basename ${BASH_SOURCE[0]}`

if [ -z $1 ] ; then
    USER_NAME=$USER
else
    USER_NAME=$1
fi

if [ -z $USER_NAME ] ; then
    echo "`ERROR $_FILE_NAME` Don't known for which user this setup should be performed, cannot continue."
    error_exit
fi

# This user (ik1614) MUST specify for which user this setup should be performed
if [ $USER_NAME == "ik1614" ] ; then
    echo "`ERROR $_FILE_NAME` Can not perform setup for [ik1614]"
    error_exit
fi

if [ -z $EE_IK1614LX_DEFAULTS_HOME ] || [ -z $CSP_ICT_HOME ]; then
    echo "`ERROR $_FILE_NAME` Missing some required variables."
    error_exit
fi

USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"
USER_BIN_HOME="${USER_HOME}/bin"
DEFAULT_BIN_SCRIPTS="${EE_IK1614LX_DEFAULTS_HOME}/default_user_bin_scripts.txt"

echo "`INFO $_FILE_NAME` Configuring convenience scripts in [${USER_BIN_HOME}]."

# '|| [[ -n $line ]]' prevents the last line being ignored if it doesn't end with a \n
while read -r line || [[ -n "$line" ]]; do

    # Skip empty lines if they exist
    [ -z "$line" ] && continue

    # Skip lines that start with a hash mark
    [[ ${line} == \#* ]] && echo "Skip copying `yellow $line`" && continue

    script_file_name="$line"
    target=$CSP_ICT_HOME/scripts/${script_file_name}
    destination=${USER_BIN_HOME}/${script_file_name}

    if [ ! -f $target ]; then
        echo "`yellow WARNING:` Couldn't copy [`red $script_file_name`], it doesn't exist."
    else
        echo "Copying `green $script_file_name`"
        cp $CSP_ICT_HOME/scripts/${script_file_name} ${USER_BIN_HOME}/${script_file_name}
    fi


done < "$DEFAULT_BIN_SCRIPTS"

cp $CSP_ICT_HOME/scripts/README.md ${USER_BIN_HOME}/README.md
