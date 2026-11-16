#!/bin/sh
# Weekly cleanup of junk that regrows on its own. Unlike disk-guard.sh, this DELETES.
#
# - Chrome code_sign_clone: every chrome-devtools-mcp launch leaves a ~2G Chrome.app clone that
#   nothing removes (11 piled up by 2026-11; du said 17G, 4.9G real after APFS block sharing).
#   Running Chrome executes from /Applications, not the clone, so deleting old ones is safe.
# - Docker: unused images, stopped containers, networks and build cache older than 7 days.
#   Volumes are never pruned: they hold database data.
#
# Installed by src/install_scripts/diskguard-setup.sh; runs weekly via launchd.
# Run now: launchctl kickstart gui/$(id -u)/com.twoody.diskcleanup   Log: /tmp/disk-cleanup.log

# launchd starts jobs with a bare PATH; docker lives in Homebrew (Apple silicon or Intel).
PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

free_gb ()
{
	/bin/df -g /System/Volumes/Data | /usr/bin/awk 'NR==2 {print $4}'
}

echo "== $(date) start, ${free_gb_before:=$(free_gb)}G free"

# getconf gives the per-user .../T/ dir; Chrome puts its clones in the sibling X/.
CLONES="$(dirname "$(getconf DARWIN_USER_TEMP_DIR)")/X/com.google.Chrome.code_sign_clone"
if [ -d "$CLONES" ];
	then
		/usr/bin/find "$CLONES" -mindepth 1 -maxdepth 1 -mtime +0 -exec rm -rf {} +
fi

# Errors out harmlessly (logged) when Docker Desktop isn't running.
if command -v docker >/dev/null;
	then
		docker system prune -af --filter until=168h
fi

echo "== $(date) done, $(free_gb)G free (was ${free_gb_before}G)"
