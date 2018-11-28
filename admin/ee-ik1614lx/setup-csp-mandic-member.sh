#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>


###--- Source convenience variables and utility functions ---###
source /hdd/csp-ict/admin/ee-ik1614lx/_variables.sh


###--- Define variables ---###
__FILE_NAME__=`basename ${BASH_SOURCE[0]}`
__HOST_NAME__=`hostname -f`
__SETUP_SUCCESS__=".initial-csp-setup.done"

SSH_USER="unknown_user"
if [ "${USER}" == "" ]; then
    echo "`ERROR $__FILE_NAME__` USER not set in the environment, cannot continue"
    error_exit
else
    echo "`INFO $__FILE_NAME__` Found USER in environment [${USER}]"
    SSH_USER="${USER}"
fi

LOG_DATE=`date '+%Y-%m-%d'`
LOG_TIME=`date '+%H-%M-%S'`
LOG_DIR="/hdd/log/initial_setup"
LOG_FILE="${SSH_USER}_${LOG_DATE}_${LOG_TIME}.log"


###--- Define functions ---###
function full_setup() {
    echo "`INFO $__FILE_NAME__` ${LOG_DATE} at ${LOG_TIME}: Starting initial configuration for [${SSH_USER}]"

    source $EE_IK1614LX_SETUP_HOME/setup-dotfiles.sh $SSH_USER
    source $EE_IK1614LX_SETUP_HOME/setup-nodejs.sh $SSH_USER
    source $EE_IK1614LX_SETUP_HOME/setup-miniconda.sh $SSH_USER
    source $EE_IK1614LX_SETUP_HOME/setup-labextensions.sh $SSH_USER

    touch ${SSH_USER_HOME}/${__SETUP_SUCCESS__}

    echo "`INFO $__FILE_NAME__` Initial configuration for CSP-Mandic member is complete" | tee ${SSH_USER_HOME}/${__SETUP_SUCCESS__}
}


##############################################
###--------          MAIN          --------###
##############################################


###--- Validate SSH_USER who tries to login ---###
GETENTPASSWD="$(getent passwd ${SSH_USER})"
if [ $? -ne 0 ]; then
    echo "`ERROR $__FILE_NAME__` Could not 'getent' for [${SSH_USER}]"
    error_exit
fi
SSH_USER_UID="$(echo ${GETENTPASSWD} | awk -F: '{ print $3 }')"
SSH_USER_GID="$(echo ${GETENTPASSWD} | awk -F: '{ print $4 }')"
SSH_USER_HOME="$(echo ${GETENTPASSWD} | awk -F: '{ print $6 }')"

if [ "${SSH_USER}" == "ik1614" ] && [ "${SSH_USER_UID}" == "698242" ]; then
    # Don't do anything, since this user is competent enough
    # to manage and maintain configuration on his own.
    echo "`INFO $__FILE_NAME__` Welcome back, your majesty."
    echo ""
    return 0
fi


###--- Check if SSH_USER present in local passwd. ---###
if grep -q "${SSH_USER}:[x*]:${SSH_USER_UID}:${SSH_USER_GID}:.*:/hdd/csp-mandic/${SSH_USER}:" /etc/passwd; then
    echo "`INFO $__FILE_NAME__` Greetings [$SSH_USER] `green ":-)"`"
else
    echo "`ERROR $__FILE_NAME__` Home directory [${SSH_USER}] is specified by LDAP. It needs to be overridden locally."
    error_exit
fi


if [ ! -d ${SSH_USER_HOME} ]; then
    echo "`ERROR $__FILE_NAME__` Home directory [${SSH_USER_HOME}] does not exist and this script will not create it"
    error_exit
fi


###--- Check if initial configuration has been performed otherwise perform it ---###
if [ -e ${SSH_USER_HOME}/.initial-csp-config.done ]; then
    echo "`INFO $__FILE_NAME__` Initial configuration is not required. Found [${SSH_USER_HOME}/`green ${__SETUP_SUCCESS__}`]."

    # Check that user have setup ssh-key after the first login
    if grep -q "ssh-.*== ${SSH_USER}@" ${SSH_USER_HOME}/.ssh/authorized_keys; then
        echo "`INFO $__FILE_NAME__` Found ssh-key in [${SSH_USER_HOME}/.ssh/authorized_keys].";
    else
        echo "`WARNING $__FILE_NAME__` Password authentication will be disabled soon but ssh-key has not been setup.";
        echo ""
        echo "To get rid of this warning follow instruction on creating ssh key and copy it to this server:"
        printf "\t cat ~/.ssh/id_rsa.pub | ssh ${SSH_USER}@${__HOST_NAME__} 'cat >> .ssh/authorized_keys && echo \"Key has been copied successfully\"' "
        echo ""
#        error_exit
#        TODO: Do not allow to login, after setting up the ssh-key is finalised for Unix and Windows remote users.
    fi
else
    ###--- Perform full setup and write log ---###
    full_setup | tee $LOG_DIR/$LOG_FILE

    echo ""
    echo "`INFO $__FILE_NAME__` Log saved in ${LOG_DIR}/${LOG_FILE}" | tee -a ${SSH_USER_HOME}/${__SETUP_SUCCESS__}
    echo ""
fi
