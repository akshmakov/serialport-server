#!/bin/sh
#
# Author: Andrey Shmakov
#
# https://github.com/akshmakov/serialport-server
#
# Simple serial port server using socat
#

 


PROGNAME=$(basename $0)
INVOKE_TS=$(date +"%s")

function error_exit
{
    #----------------------------------------------------------------
    # Function for exit due to fatal program error
    # Accepts 1 argument:
    # string containing descriptive error message
    #----------------------------------------------------------------
    echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    exit 1
}

function usage
{
        cat <<EOF
Usage: $PROGNAME [OPTIONS] device 

options: 
     -p/--port=<PORT>         : exposed TCP Port (default=2000) 
     -b/--tty-br=<BAUDRATE>   : baud rate of underlying device (default=9600)
     -l/--logfile=<FNAME>     : save output to file
     -h/--help                : print this usage
     -d/--daemon              : daemonize (background) 
     -v/--verbose             : more (debug) 

device: local socket or device (e.g. /dev/ttyUSB0)

The following Environment Variables can be used in lieu of args
$PORT     - TCP Port
$BAUDRATE - Baudrate
$DEVICE   - device 
EOF
	exit 0

}




## Global VARS

PORT=${PORT-2000}
BAUDRATE=${BAUDRATE-9600}
#VERBOSE
#DAEMON
#LOGFILE
#DEVICE

## Following Parses the -abc/--do-thing-xyz options
## Most options modify one of the service variables above
## A few set Application Flags
## Command Processing Happens After

if [[ $# = 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]
do
    key="$1"

    
    case $key in
	-p|--port)
	    PORT=$2
	    shift
	    shift
	    ;;
	-b|--tty-br)
	    BAUDRATE=$2
	    shift
	    shift
	    ;;
	-h|--help)
	    usage
	    error_exit "Should Not Get Here"
	    ;;
	-l|--logfile)
	    LOGFILE=$2
	    shift
	    shift
	    ;;
	-d|--daemon)
	    DAEMON=1
	    shift
	    ;;
	-v|--verbose)
	    VERBOSE=1
	    shift
	    ;;
	-*|--*)
	    # unknown option
	    error_exit "Unknown Option $1"
	    ;;
	*)
	    break
	    ;;
    esac
done

## All options have "-" or "--"
## First string after options is our command
## Command Arguments can be added later
if [[ -n $1 ]]; then
    DEVICE=$1
elif [[ -z DEVICE ]]; then
    error_exit "You need to specify a device"
fi

echo "Device: $DEVICE"



### setup verbose mode
# Nifty Trick found on SO
# You can write your own verbose only
# log string by repacing your
# echo "text string here"
# with
# echo "text string here" >&3
# for stdout (verbose)
# and >&4 for stderr (verbose)
###
if [ ! -z $VERBOSE ]; then
    exec 4>&2 3>&1
else
    exec 4>/dev/null 3>/dev/null
fi



cat <<-EOF >&3
External Port: $PORT
Host Device:   $DEVICE
       BAUD:   $BAUDRATE
Log File : ${LOGFILE-NONE}
Daemon : `if [ -z $DAEMON ]; then echo "no"; else echo "yes"; fi`
EOF




## Socat

#socat -d -d -v  tcp4-listen:2000,reuseaddr,fork file:/dev/ttyUSB0,raw,nonblock,echo=0,waitlock=/var/run/tty


SOCAT_BIN=socat
SOCAT_OPTS="-v"
SOCAT_TCP_PRE=tcp4-listen
SOCAT_TCP_POST="reuseaddr"

SOCAT_FILE_PRE=file
SOCAT_FILE_POST="raw,nonblock,echo=0"


if [ -n $VERBOSE ]; then
    SOCAT_OPTS="-d -d -v"
fi

SOCAT_INVOCATION="$SOCAT_BIN $SOCAT_OPTS \
	   $SOCAT_TCP_PRE:$PORT,$SOCAT_TCP_POST \
	   $SOCAT_FILE_PRE:$DEVICE,$SOCAT_FILE_POST"


echo $SOCAT_INVOCATION >&3

stty -F $DEVICE $BAUDRATE


if [ -z $LOGFILE]; then
   $SOCAT_INVOCATION
else 
   $SOCAT_INVOCATION 2>&1 > $LOGFILE
fi


#socat -d -d -v PTY,link=/dev/ttytun,raw,echo=0 FILE:/dev/ttyUSB0,raw,nonblock,echo=0

