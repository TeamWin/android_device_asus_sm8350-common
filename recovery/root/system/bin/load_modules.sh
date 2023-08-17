#!/sbin/sh

# The below variables shouldn't need to be changed
# unless you want to call the script something else
SCRIPTNAME="load_modules"
LOGFILE=/tmp/recovery.log

# Set default log level
DEFAULT_LOGLEVEL=1
# 0 Errors only
# 1 Errors and Information
# 2 Errors, Information, and Debugging
CUSTOM_LOGLEVEL=$(getprop $SCRIPTNAME.loglevel)
if [ -n "$CUSTOM_LOGLEVEL" ]; then
    __VERBOSE="$CUSTOM_LOGLEVEL"
else
    __VERBOSE="$DEFAULT_LOGLEVEL"
fi

# Exit codes:
# 0 Success
# 1 Unknown encryption type
# 2 Temp Mount Failure

# Function for logging to the recovery log
log_print()
{
	# 0 = Error; 1 = Information; 2 = Debugging
	case $1 in
		0|error)
			LOG_LEVEL="E"
			;;
		1|info)
			LOG_LEVEL="I"
			;;
		2|debug)
			LOG_LEVEL="DEBUG"
			;;
		*)
			LOG_LEVEL="UNKNOWN"
			;;
	esac
	if [ "$__VERBOSE" -ge "$1" ]; then
		echo "$LOG_LEVEL:$SCRIPTNAME::$2" >> "$LOGFILE"
	fi
}

check_resetprop()
{
	if [ -e /system/bin/resetprop ] || [ -e /sbin/resetprop ]; then
		log_print 2 "Resetprop binary found!"
		setprop_bin=resetprop
	else
		log_print 2 "Resetprop binary not found. Falling back to setprop."
		setprop_bin=setprop
	fi
}

finish()
{
	log_print 1 "$SCRIPTNAME complete."
	$setprop_bin $SCRIPTNAME.complete 1
	exit 0
}

modprobe_load()
{
	modprobe -d "$1" -v -v -s --all="$1/$2"
}

log_print 1 "Running $SCRIPTNAME script for TWRP..."

check_resetprop
modules_path="/vendor/lib/modules/1.1"
modprobe_load "$modules_path" "modules.load"

finish
