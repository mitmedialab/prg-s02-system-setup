#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo "error: run this script as root"
    exit 1
fi

NET_RULES_FILE="/etc/udev/rules.d/70-persistent-net.rules"

nuc_model=`dmesg | egrep "Intel.*NUC" | cut -d: -f2 | cut -d, -f1`
os_version=`(source /etc/os-release; echo $VERSION)`

wlan0_mac=`iw dev wlan0 info | egrep addr | cut -d" " -f 2`
wlan1_mac=`iw dev wlan1 info | egrep addr | cut -d" " -f 2`

mac0_database="`curl -s https://www.macvendorlookup.com/api/v2/$wlan0_mac`"
mac1_database="`curl -s https://www.macvendorlookup.com/api/v2/$wlan1_mac`"

vendor0="`echo \"$mac0_database\" | sed 's/.*"company":"\([^"]*\).*/\1/'`"
vendor1="`echo \"$mac1_database\" | sed 's/.*"company":"\([^"]*\).*/\1/'`"

echo "NUC: $nuc_model"
echo "os: $os_version"
echo

if [[ -e $NET_RULES_FILE ]]; then
    echo "there is an existing $NET_RULES_FILE file:"
    cat $NET_RULES_FILE
else
    echo "no existing net rules file"
fi
echo

echo "current wlan order"
echo "wlan0: $wlan0_mac ($vendor0)"
echo "wlan1: $wlan1_mac ($vendor1)"

command="$1"
if [[ ! $command ]]; then
    echo
    echo "lock   - create rule to just lock wlan0 (only use when wlan0 is internal adaptor)"
    echo "swap   - create rules to swap wlan0 and wlan1"
    echo "unlock - remove rules (undo \"lock\" or \"swap\")"
    echo
    read -p "lock, swap, unlock, or quit [quit]? " command
fi
echo

case $command in
    lock )
	echo "creating $NET_RULES_FILE to swap wlan0 and wlan1..."
	cat <<-EOF > $NET_RULES_FILE
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="$wlan0_mac", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan0"
	EOF
	;;

    swap )
	echo "creating $NET_RULES_FILE to swap wlan0 and wlan1..."
	cat <<-EOF > $NET_RULES_FILE
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="$wlan0_mac", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan1"
		SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="$wlan1_mac", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan0"
	EOF
	;;

    unlock )
	echo "removing $NET_RULES_FILE..."
	rm $NET_RULES_FILE
	;;

    ""|* )
	echo "quitting"
	;;
esac

echo "done."
echo "reboot for any changes to take effect"



