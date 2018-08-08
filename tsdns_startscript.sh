#!/bin/bash
#
# Copyright (c) TeamSpeak Systems GmbH. All rights reserved.
#
### BEGIN INIT INFO
# Provides: tsdnsserver-linux
# Required-Start: $local_fs $network
# Required-Stop: $local_fs $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: TSDNS Server
# Description: Resolves hostnames to IP and port numbers
### END INIT INFO

# EDIT THIS
BINARYPATH="/path/to/folder/tsdns" # path to the TSDNS folder

# DO NOT EDIT IF YOU DON'T KNOW WHAT YOU ARE DOING!!!
BINARYNAME="tsdnsserver"

cd "${BINARYPATH}"
LIBRARYPATH="$(pwd)"

case "$1" in
    start)
        if [ -e tsdnsserver.pid ]; then
            if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
                echo "The server is already running, try restart or stop..."
                exit 1
            else
                echo "tsdnsserver.pid found, but no server running. Possibly your previously started server crashed..."
                echo "Please view the logfile for details."
                rm tsdnsserver.pid
            fi
        fi
        if [ "${UID}" = "0" ]; then
            echo "WARNING: For security reasons we advise: DO NOT RUN THE SERVER AS ROOT!!!"
            for c in $(seq 1 10); do
                echo -n "!"
                sleep 1
            done
            echo "!"
        fi
        echo "Starting the TSDNS Server."
        if [ -e "$BINARYNAME" ]; then
            if [ ! -x "$BINARYNAME" ]; then
                echo "${BINARYNAME} is not executable, trying to set it..."
                chmod u+x "${BINARYNAME}"
            fi
            if [ -x "$BINARYNAME" ]; then
                export LD_LIBRARY_PATH="${LIBRARYPATH}:${LD_LIBRARY_PATH}"
                "./${BINARYNAME}" > /dev/null &
                echo $! > tsdnsserver.pid
                echo "TSDNS Server started, for details please view the log file..."
            else
                echo "${BINARNAME} is not exectuable, cannot start TSDNS Server..."
            fi
        else
            echo "Could not find ${BINARYNAME}, aborting..."
            exit 5
        fi
    ;;
    stop)
        if [ -e tsdnsserver.pid ]; then
            echo -n "Stopping the TSDNS Server."
            if ( kill -TERM $(cat tsdnsserver.pid) 2> /dev/null ); then
                for c in $(seq 1 300); do
                    if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
                        echo -n "."
                        sleep 1
                    else
                        break
                    fi
                done
            fi
            if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
                echo "Server is not shutting down cleanly - killing..."
                kill -KILL $(cat tsdnsserver.pid)
            else
                echo "done"
            fi
            rm tsdnsserver.pid
        else
            echo "No server runing (tsdnsserver.pid is missing)..."
            exit 7
        fi
    ;;
    update)
        if [ -e tsdnsserver.pid ]; then
            echo "Updating the TSDNS Server."
            export LD_LIBRARY_PATH="${LIBRARYPATH}:${LD_LIBRARY_PATH}"
            "./${BINARYNAME}" --update > /dev/null &
            echo "TSDNS Server updated, for details please view the log file..."
        else
            echo "No server runing (tsdnsserver.pid is missing)..."
            exit 7
        fi
    ;;
    restart)
        $0 stop && $0 start || exit 1
    ;;
    status)
        if [ -e tsdnsserver.pid ]; then
            if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
                echo "Server is running."
            else
                echo "Server seems to have died."
            fi
        else
            echo "No server running (tsdnsserver.pid is missing)..."
        fi
    ;;
    *)
        echo "Usage: ${0} {start|stop|update|restart|status}"
        exit 2
esac
exit 0
