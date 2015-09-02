#!/usr/bin/env bash

CURRENT_DIR="$(readlink -f `dirname $0`)"
[ -z "$VERBOSE"                 ] && VERBOSE=0
[ -z "$SCRIPT_SEARCH_DIR"       ] && SCRIPT_SEARCH_DIR=$CURRENT_DIR
[ -z "$DOCKER_CONTAINER"        ] && DOCKER_CONTAINER="debian:wheezy"
[ -z "$DOCKER_MOUNT_HOST"       ] && DOCKER_MOUNT_HOST=$CURRENT_DIR
[ -z "$DOCKER_MOUNT_GUEST"      ] && DOCKER_MOUNT_GUEST="/tmp/vpsc-test"
[ -z "$DOCKER_CMD_BEFORE"       ] && DOCKER_CMD_BEFORE=
[ -z "$DOCKER_CMD_AFTER"        ] && DOCKER_CMD_AFTER=
[ -z "$DOCKER_UPDATE_APT_INDEX" ] && DOCKER_UPDATE_APT_INDEX=0


function show_help() {
    echo "Usage: $(basename "$0") [options] [<files>]

  -v  Show complete output (stdout and stderr) of the test runs.
  -b  Set command which should be executed before any other files.
      Example: ./$(basename "$0") -b 'cat /etc/debian_version && uname -a' [<files>]
  -a  Set command which should be executed after any other files.
      This e.g. allows you to start a shell and attach to the container.
      Example: ./$(basename "$0") -a '/bin/bash' [<files>]
  -u  Runs 'apt-get update' before executing actual files.
      Same as: ./$(basename "$0") -b 'apt-get update > /dev/null' [<files>]
  -h  Print this help."
}


OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts ":hvb:a:u" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        v)
            VERBOSE=1
            ;;
        b)
            DOCKER_CMD_BEFORE=$OPTARG
            ;;
        a)
            DOCKER_CMD_AFTER=$OPTARG
            ;;
        u)
            DOCKER_UPDATE_APT_INDEX=1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.


if [ ! -z "$SCRIPTS" ]; then
    # env variable was set
    SCRIPTS=$SCRIPTS
elif [ $# -gt 0 ]; then
    # use given arguments
    SCRIPTS=$@
else
    # no arguments given, test all scripts (exclude current script)
    SCRIPTS=`find $SCRIPT_SEARCH_DIR -not -name "$(basename "$0")" -type f -name "*.sh"`
fi


# process every script
for SCRIPT in $SCRIPTS; do

    # transform absolute to realative path
    SCRIPT=$(echo "$SCRIPT" | sed "s#$CURRENT_DIR/##")

    echo "########## Testing: $SCRIPT"

    # check if script file exists
    if [ ! -f $SCRIPT ]; then
        echo -e "\033[31mERROR: '$SCRIPT' does not exist.\033[m"
        exit 1
    fi

    # bash syntax check
    if ! /usr/bin/env bash -n $SCRIPT; then
        echo -e "\033[31mERROR: '$SCRIPT' contains syntax errors.\033[m"
        exit 1
    fi

    # prepare execute command
    DOCKER_EXECUTE_CMD="$DOCKER_MOUNT_GUEST/$SCRIPT"
    if [ ! -z "$DOCKER_CMD_BEFORE" ]; then
        DOCKER_EXECUTE_CMD="$DOCKER_CMD_BEFORE && $DOCKER_EXECUTE_CMD"
    fi
    if [ ! -z "$DOCKER_CMD_AFTER" ]; then
        DOCKER_EXECUTE_CMD="$DOCKER_EXECUTE_CMD && $DOCKER_CMD_AFTER"
    fi
    if [ "$DOCKER_UPDATE_APT_INDEX" -eq 1 ]; then
        DOCKER_EXECUTE_CMD="echo -n '>>> Updating apt index... ' && apt-get update > /dev/null && echo 'Done.' && $DOCKER_EXECUTE_CMD"
    fi

    # set up a subshell, so the exec does only affect the content of this subshell
    (
        # show output depending on VERBOSE variable
        [ "$VERBOSE" -eq 1 ] || exec >/dev/null 2>&1

        [ ! -z "$TERM" ] && DOCKER_RUN_OPTS="-t -i"

        # actually run prepared command in docker container
        docker run \
            $DOCKER_RUN_OPTS \
            --rm \
            -v "$DOCKER_MOUNT_HOST":"$DOCKER_MOUNT_GUEST" \
            $DOCKER_CONTAINER \
            /usr/bin/env bash -c "$DOCKER_EXECUTE_CMD"
    )

    # print test result
    if [ $? -eq 0 ]; then
        echo -e "\033[32mTest for '$SCRIPT' was successful.\033[m"
    else
        echo -e "\033[31mERROR: Test execution of '$SCRIPT' failed!\033[m" 1>&2
        exit 1
    fi
done
