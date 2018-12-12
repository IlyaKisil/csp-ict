#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename ${BASH_SOURCE[0]}`

cat << HELP_USAGE

Description:
    Shows what processes users are running

Usage: $_FILE_NAME [-h|--help] [-o=|--option=<option_value>]

Examples:
    $_FILE_NAME -o=my_value
    $_FILE_NAME --option=my_value

Options:
    -h|--help
        Show this message.

    -o=|--option=<option_value>
        Use key value option.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

# Utility functions


# Default values for variables
option_value="default_value"


# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -o=*|--option=*)
            option_value="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

# Define new variables with respect to the parsed arguments


##########################################
#--------          MAIN          --------#
##########################################
echo "INFO: At the moment this script does not do anything."
exit 0
# short version
w -hs | awk '{printf "%10.10s ", $1 ; $1=$2=$3=$4="";  print $0}' | sort | uniq


# Longer version with a little bit of logic
w -hs | \
awk '{
    if ($1 != "ik1614"){
        printf "%10.10s \t %10.10s ", $1, $3;
        $1=$2=$3=$4="";
        print $0;
    }
}' | \
sort | \
uniq

# Customised output of ps. Then this can be additionally processed by 'awk'
ps axo start,time,pid,comm,user
ps axo user:30,start,time,pid,comm
