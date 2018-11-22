#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

_FILE_NAME=`basename ${BASH_SOURCE[0]}`
SSH_USER=""
HOST_NAME=`hostname -f`

source /hdd/csp-ict/admin/ee-ik1614lx/_variables.sh
source $CSP_ICT_HOME/admin/scripts/print_utils.sh



if [ "${USER}" == "" ]; then
    echo "`ERROR $_FILE_NAME` USER not set in the environment, cannot continue"
    return 0
else
    echo "`INFO $_FILE_NAME` Found USER in environment [${USER}]"
    SSH_USER="${USER}"
fi

GETENTPASSWD="$(getent passwd ${SSH_USER})"
if [ $? -ne 0 ]; then
    echo "`ERROR $_FILE_NAME` Could not 'getent' for [${SSH_USER}], exiting"
    error_exit
fi

SSH_USER_UID="$(echo ${GETENTPASSWD} | awk -F: '{ print $3 }')"
SSH_USER_GID="$(echo ${GETENTPASSWD} | awk -F: '{ print $4 }')"
SSH_USER_HOME="$(echo ${GETENTPASSWD} | awk -F: '{ print $6 }')"

if grep -q "${SSH_USER}:[x*]:${SSH_USER_UID}:${SSH_USER_GID}:" /etc/passwd; then
    echo "`INFO $_FILE_NAME` Greetings [$SSH_USER] `green ":-)"`"
else
    echo "`ERROR $_FILE_NAME` `red "[${SSH_USER}]"` have not been granted an access. Contact CSP-ICT administrator. Exiting"
    return 0
fi



if [ "${SSH_USER}" == "ik1614" ]; then
    # Don't do anything, since this user is competent enough
    # to manage and maintain configuration on his own.
    echo "`INFO $_FILE_NAME` Welcome back, your majesty."
    echo ""
    return 0
fi



echo "`INFO $_FILE_NAME` Starting initial configuration for [${SSH_USER}]"

if [ ! -d ${SSH_USER_HOME} ]; then
    echo "`ERROR $_FILE_NAME` The home directory [${SSH_USER_HOME}] does not exist and this script will not create it. Exiting"
    return 0
fi

if [ -e ${SSH_USER_HOME}/.initial-csp-config.done ]; then
    echo "`INFO $_FILE_NAME` Found ${SSH_USER_HOME}/.initial-csp-config.done. Initial configuration is not required."

    # Check that user have setup ssh-key after the first login
    if [[ -s diff.txt ]]; then
        echo "`INFO $_FILE_NAME` Found ssh-key in (${SSH_USER_HOME}/.ssh/authorized_keys is not empty).";
    else
        echo "`WARNING $_FILE_NAME` Password authentication will be disabled soon but ssh-key has not been setup.";
        echo ""
        echo "To get rid of this warning follow instruction on creating ssh key and copy it to this server:"
        echo ""
        echo "cat ~/.ssh/id_rsa.pub | ssh ${SSH_USER}@${HOST_NAME} 'cat >> .ssh/authorized_keys && echo \"Key has been copied successfully\"' "
        echo ""
#        printf "Enter [y] to proceed: "
#        answer=$( while ! head -c 1 | grep -i '[y]' ;do true ;done )
        # exit 0;
        return 0
    fi
    return 0
fi

source $EE_IK1614LX_SETUP_HOME/setup-dotfiles.sh $SSH_USER
source $EE_IK1614LX_SETUP_HOME/setup-nodejs.sh $SSH_USER_HOME
source $EE_IK1614LX_SETUP_HOME/setup-miniconda.sh $SSH_USER_HOME

touch ${SSH_USER_HOME}/.initial-csp-config.done
echo "`INFO $_FILE_NAME` Initial configuration for CSP-Mandic member is complete"
echo ""
echo ""
