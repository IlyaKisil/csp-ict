#! /bin/bash

# Author: Ilya Kisil <ilyakisil@gmail.com>


##########################################
###--------   Default values   --------###
##########################################
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
WHITE="\033[0;0m"


#########################################
###--------     Functions     --------###
#########################################
function red(){
    printf "${RED}$1${WHITE}"
}

function green(){
    printf "${GREEN}$1${WHITE}"
}

function yellow(){
    printf "${RED}$1${WHITE}"
}

function INFO(){
    local FILE_NAME
    FILE_NAME=$1
    echo -e "`green "\nINFO: ${FILE_NAME}"`\n===>"
}

function WARNING(){
    local FILE_NAME
    FILE_NAME=$1
    echo -e "`yellow "\nWARNING: ${FILE_NAME}"`\n===>"
}

function ERROR(){
    local FILE_NAME
    FILE_NAME=$1
    echo -e "`red "\nERROR: ${FILE_NAME}"`\n===>"
}

function error_exit(){
    printf "Enter [y] to exit: "
    answer=$( while ! head -c 1 | grep -i '[y]' ;do true ;done )
    exit 0
}
