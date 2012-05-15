#! /bin/sh
#
# Arguments: pbuser pbpwd userid subdirectories
#

badArgs() {
	echo "Install failed. Bad argument list."
	echo "Arguments are pinboard userid, pinboard password, user subdirectory"
	exit 2
}

# Capture substitution values
#
if [ -z "$1" ]
then
	PBUSER_=$1
else
	badArgs
fi
if [ -z "$2" ]
then
	PBPWD_=$2
else
	badArgs
fi
if [ -z "$3" ]
then
	SUBDIR_=$3
else
	badArgs
fi
UID_=`whoami`

# Copy script to SUBDIR_
#
SCRIPTTGT_=/Users/$UID_/$SUBDIR_/backup-pinboard.sh
AGENTTGT_=/Users/$UID_/Library/LaunchAgents/net.localhost.PinboardBackup.plist
OVERWRITE_=0
if [ -e "$SCRIPTTGT_" ] \
|| [ -e "$AGENTTGT_" ]
then
	echo -n "Do you want to overwrite existing files? [yes/no] "
	read YN_
	if [[ "yes" -ne $YN_ ]]
	then
		echo "Aborting install; existing files."
		exit 4
	fi
	OVERWRITE_=1
fi

if [ -e "$AGENTTGT_" ]
then
	luanchctl unload -w -S Background "$AGENTTGT_"
fi

cat backup-pinboard.sh | \
	sed s/{{pbuser}}/$PBUSER_/ | \
	sed s/{{pbpwd}}/$PBPWD_/ > \
	"$SCRIPTTGT_"
cat net.localhost.PinboardBackup.plist | \
	sed s/{{userid}}/$UID_/ | \
	sed s/{{subdir}}/$SUBDIR_ > \
	"$AGENTTGT_"

launchctl load -w -S Background "$AGENTTGT_"