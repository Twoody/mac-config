#!/bin/sh
# Warns when the disk is low or an app's logs run away. NOTIFY ONLY - deletes nothing.
#
# Why this exists: on 2026-07-24 the Reolink desktop app spammed ~1,140 rotated log files
# (~23G in two hours) into ~/Library/Logs/reolink, filling the disk to 99%. Docker Desktop's
# VM then could not write and its engine crash-looped, which presents as "Docker won't start"
# with no obvious connection to disk space.
#
# Installed by src/install_scripts/diskguard-setup.sh; runs hourly via launchd.
#
# To clean up after a warning (keeps the live main.log and current-day SDK log):
#   find ~/Library/Logs/reolink -maxdepth 1 -type f -name 'SDK.*.log.*' -delete
#
# If Docker is already wedged: kill -9 the com.docker.backend pid (AppleScript "quit" hangs
# on Docker's error dialog), then `open -a Docker`.

FREE_MIN_GB=25
LOGDIR_MAX_MB=2048

# Log directories to watch for runaway growth. Missing ones are skipped silently,
# so this list is safe to carry to a machine that has none of these apps.
WATCH_DIRS="$HOME/Library/Logs/reolink"

# @param {string} $1 - notification title
# @param {string} $2 - notification body
notify ()
{
	/usr/bin/osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1
}

free_gb=$(/bin/df -g /System/Volumes/Data 2>/dev/null | /usr/bin/awk 'NR==2 {print $4}')
case "$free_gb" in
[0-9]*)
	if [ "$free_gb" -lt "$FREE_MIN_GB" ];
		then
			notify "Disk space low" "${free_gb}G free. Check the log dirs in disk-guard.sh, then 'docker system df'."
	fi
	;;
esac

for dir in $WATCH_DIRS;
do
	[ -d "$dir" ] || continue
	dir_mb=$(/usr/bin/du -sm "$dir" 2>/dev/null | /usr/bin/cut -f1)
	case "$dir_mb" in
	[0-9]*)
		if [ "$dir_mb" -gt "$LOGDIR_MAX_MB" ];
			then
				notify "Logs running away" "${dir_mb}MB in $dir - see disk-guard.sh header to prune."
		fi
		;;
	esac
done
