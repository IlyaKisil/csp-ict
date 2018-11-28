#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>


_FILE_NAME=`basename ${BASH_SOURCE[0]}`

USER_NAME=$1
USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"
USER_BIN_HOME="${USER_HOME}/bin"
DEFAULT_BIN_SCRIPTS="${EE_IK1614LX_SETUP_HOME}/default_user_bin_scripts.txt"

echo "`INFO $_FILE_NAME` Configuring convenience scripts in [${USER_BIN_HOME}]."


# '|| [[ -n $line ]]' prevents the last line from being ignored if it doesn't end with a \n
while read -r line || [[ -n "$line" ]]; do

    # Skip empty lines if they exist
    [ -z "$line" ] && continue

    script_file_name="$line"
    printf "\t Copying `green $script_file_name` \n"
    cp $CSP_ICT_HOME/scripts/${script_file_name} ${USER_BIN_HOME}/${script_file_name}
done < "$DEFAULT_BIN_SCRIPTS"

cp $CSP_ICT_HOME/scripts/README.md ${USER_BIN_HOME}/README.md
