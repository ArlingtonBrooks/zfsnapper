#!/bin/bash

# ZFS Pool Name
POOL_NAME="d2"

# Set number of snapshots to keep:
N_HOURLY=24
N_DAILY=14
N_WEEKLY=4
N_MONTHLY=3

# Set the name of the snapshot prefix
SNAPSHOT_PREFIX_HOURLY="hourly"
SNAPSHOT_PREFIX_DAILY="daily"
SNAPSHOT_PREFIX_WEEKLY="weekly"
SNAPSHOT_PREFIX_MONTHLY="monthly"

function ReadAllSnapshots() {
	SNAPSHOTS=$(zfs list -H -r -t snapshot -o name "${POOL_NAME}" | sort)
}

# Get the date and set relevant variables
function GetDateVariables() {
	DATE=$(date "+%Y-%m-%d")
	DATE_HR=$(date "+%H")
	DATE_DAILY=$(date "+%Y-%m-%d")
	DATE_WEEKLY=$(date "+%Y-%U")
	DATE_MONTHLY=$(date "+%Y-%m")
}

function SetSnapshotNames() {
	# Create the snapshot name using the prefix and date
	SNAPSHOT_NAME_HOURLY="${SNAPSHOT_PREFIX_HOURLY}_${DATE}_${DATE_HR}"
	SNAPSHOT_NAME_DAILY="${SNAPSHOT_PREFIX_DAILY}_${DATE_DAILY}"
	SNAPSHOT_NAME_WEEKLY="${SNAPSHOT_PREFIX_WEEKLY}_${DATE_WEEKLY}"
	SNAPSHOT_NAME_MONTHLY="${SNAPSHOT_PREFIX_MONTHLY}_${DATE_MONTHLY}"
}

# Process and create hourly snaps
function ProcessHourlySnapshots() {
	if [[ ${POOL_NAME} == "" ]]; then 
		echo "NO POOL SET"
		exit 1
	elif [[ ${SNAPSHOT_NAME_HOURLY} == "" ]]; then 
		echo "NO HOURLY DATE SET"
		exit 1
	fi
	# Create the snapshot
	if [ $CREATE -eq 1 ]; then 
		zfs snapshot -r "${POOL_NAME}@${SNAPSHOT_NAME_HOURLY}"
	else
		echo "(not creating ${POOL_NAME}@${SNAPSHOT_NAME_HOURLY})"
	fi

	# Get the list of all snapshots for the Zpool
	local SNAPSHOTS_HOURLY=$( echo "$SNAPSHOTS" | grep $SNAPSHOT_PREFIX_HOURLY | nl )

	local MAX_N_SNAPS_HOURLY=$( echo "$SNAPSHOTS_HOURLY" | tail -n 1 | xargs | cut -d' ' -f1)
	local DESTROY_BEFORE=$( expr $MAX_N_SNAPS_HOURLY - $N_HOURLY )

	# Loop through each snapshot and check if it's older than 14 days
	while read snapshot; do #for snapshot in $SNAPSHOTS_HOURLY; do
		local HOURLY_SNAP_NAME=$( echo "$snapshot" | xargs | cut -d' ' -f2)
		local HOURLY_SNAP_NUM=$( echo "$snapshot" | xargs | cut -d' ' -f1 )
		if [ "$HOURLY_SNAP_NUM" -lt "$DESTROY_BEFORE" ]; then
			#echo "$HOURLY_SNAP_NUM"
			#echo "$DESTROY_BEFORE"
			# Delete the snapshot if it's older than 14 days
			echo "Destroying $snapshot"
			if [ $DESTROY -eq 1 ]; then 
				zfs destroy "$HOURLY_SNAP_NAME"
			else
				echo "(not destroying $HOURLY_SNAP_NAME)"
			fi
		fi
	done < <(echo "$SNAPSHOTS_HOURLY")
}

# Process and create daily snaps
function ProcessDailySnapshots() {
	if [[ ${POOL_NAME} == "" ]]; then 
		echo "NO POOL SET"
		exit 1
	elif [[ ${SNAPSHOT_NAME_DAILY} == "" ]]; then 
		echo "NO DAILY DATE SET"
		exit 1
	fi
	if [[ $(echo "$SNAPSHOTS" | grep "$SNAPSHOT_PREFIX_DAILY" | sort | tail -n 1)  == "$POOL_NAME@$SNAPSHOT_NAME_DAILY" ]]; then 
		echo "Daily exists"
	else
		echo "Creating daily snapshot ${POOL_NAME}@${SNAPSHOT_NAME_DAILY}"
		# Create the snapshot
		if [ $CREATE -eq 1 ]; then 
			zfs snapshot -r "${POOL_NAME}@${SNAPSHOT_NAME_DAILY}"
		else
			echo "(not creating ${POOL_NAME}@${SNAPSHOT_NAME_DAILY})"
		fi
		
		# Get the list of all snapshots for the Zpool
		local SNAPSHOTS_DAILY=$( echo "$SNAPSHOTS" | grep $SNAPSHOT_PREFIX_DAILY | nl )
		
		local MAX_N_SNAPS_DAILY=$( echo "$SNAPSHOTS_DAILY" | tail -n 1 | xargs | cut -d' ' -f1)
		local DESTROY_BEFORE=$( expr $MAX_N_SNAPS_DAILY - $N_DAILY )
		
		# Loop through each snapshot and check if it's older than 14 days
		while read snapshot; do #for snapshot in $SNAPSHOTS_DAILY; do
			local DAILY_SNAP_NAME=$( echo "$snapshot" | xargs | cut -d' ' -f2)
			local DAILY_SNAP_NUM=$( echo "$snapshot" | xargs | cut -d' ' -f1 )
			if [ "$DAILY_SNAP_NUM" -lt "$DESTROY_BEFORE" ]; then
				# Delete the snapshot if it's older than 14 days
				echo "Destroying $snapshot"
				if [ $DESTROY -eq 1 ]; then 
					zfs destroy "$DAILY_SNAP_NAME"
				else
					echo "(not destroying $DAILY_SNAP_NAME)"
				fi
			fi
		done < <(echo "$SNAPSHOTS_DAILY")
	fi
}

# Process and create weekly snapshots
function ProcessWeeklySnapshots() {
	if [[ ${POOL_NAME} == "" ]]; then 
		echo "NO POOL SET"
		exit 1
	elif [[ ${SNAPSHOT_NAME_DAILY} == "" ]]; then 
		echo "NO WEEKLY DATE SET"
		exit 1
	fi
	if [[ $(echo "$SNAPSHOTS" | grep $SNAPSHOT_PREFIX_WEEKLY | tail -n 1)  == "$POOL_NAME@$SNAPSHOT_NAME_WEEKLY" ]]; then 
		echo "Weekly exists"
	else
		echo "Creating daily snapshot ${POOL_NAME}@${SNAPSHOT_NAME_WEEKLY}"
		# Create the snapshot
		if [ $CREATE -eq 1 ]; then 
			zfs snapshot -r "${POOL_NAME}@${SNAPSHOT_NAME_WEEKLY}"
		else
			echo "(not creating ${POOL_NAME}@${SNAPSHOT_NAME_WEEKLY})"
		fi
		
		# Get the list of all snapshots for the Zpool
		local SNAPSHOTS_WEEKLY=$( echo "$SNAPSHOTS" | grep $SNAPSHOT_PREFIX_WEEKLY | nl )
		
		local MAX_N_SNAPS_WEEKLY=$( echo "$SNAPSHOTS_WEEKLY" | tail -n 1 | xargs | cut -d' ' -f1)
		local DESTROY_BEFORE=$( expr $MAX_N_SNAPS_WEEKLY - $N_WEEKLY )
		
		# Loop through each snapshot and check if it's older than 14 days
		while read snapshot; do #for snapshot in $SNAPSHOTS_WEEKLY; do
			local WEEKLY_SNAP_NAME=$( echo "$snapshot" | xargs | cut -d' ' -f2)
			local WEEKLY_SNAP_NUM=$( echo "$snapshot" | xargs | cut -d' ' -f1 )
			if [ "$WEEKLY_SNAP_NUM" -lt "$DESTROY_BEFORE" ]; then
				# Delete the snapshot if it's older than 14 days
				echo "Destroying $snapshot"
				if [ $DESTROY -eq 1 ]; then 
					zfs destroy "$WEEKLY_SNAP_NAME"
				else
					echo "(not destroying $WEEKLY_SNAP_NAME)"
				fi
			fi
		done < <(echo "$SNAPSHOTS_WEEKLY")
	fi
}

function ProcessMonthlySnapshots() {
	if [[ ${POOL_NAME} == "" ]]; then 
		echo "NO POOL SET"
		exit 1
	elif [[ ${SNAPSHOT_NAME_DAILY} == "" ]]; then 
		echo "NO MONTHLY DATE SET"
		exit 1
	fi
	if [[ $(echo "$SNAPSHOTS" | grep $SNAPSHOT_PREFIX_MONTHLY | tail -n 1)  == "$POOL_NAME@$SNAPSHOT_NAME_MONTHLY" ]]; then 
		echo "Monthly exists"
	else
		echo "Creating daily snapshot ${POOL_NAME}@${SNAPSHOT_NAME_MONTHLY}"
		# Create the snapshot
		if [ $CREATE -eq 1 ]; then 
			zfs snapshot -r "${POOL_NAME}@${SNAPSHOT_NAME_MONTHLY}"
		else
			echo "(not creating ${POOL_NAME}@${SNAPSHOT_NAME_MONTHLY})"
		fi
		
		# Get the list of all snapshots for the Zpool
		local SNAPSHOTS_MONTHLY=$( echo "$SNAPSHOTS" | grep $SNAPSHOT_PREFIX_MONTHLY | nl )
		
		local MAX_N_SNAPS_MONTHLY=$( echo "$SNAPSHOTS_MONTHLY" | tail -n 1 | xargs | cut -d' ' -f1)
		local DESTROY_BEFORE=$( expr $MAX_N_SNAPS_MONTHLY - $N_MONTHLY )
		
		# Loop through each snapshot
		while read snapshot; do #for snapshot in $SNAPSHOTS_MONTHLY; do
			local MONTHLY_SNAP_NAME=$( echo "$snapshot" | xargs | cut -d' ' -f2)
			local MONTHLY_SNAP_NUM=$( echo "$snapshot" | xargs | cut -d' ' -f1 )
			if [ "$MONTHLY_SNAP_NUM" -lt "$DESTROY_BEFORE" ]; then
				# Delete the snapshot if it's older than 14 days
				echo "Destroying $snapshot"
				if [ $DESTROY -eq 1 ]; then 
					zfs destroy "$MONTHLY_SNAP_NAME"
				else
					echo "(not destroying $MONTHLY_SNAP_NAME)"
				fi
			fi
		done < <(echo "$SNAPSHOTS_MONTHLY")
	fi
}

#
#----------------------------------------------------
# Check for input flags
#----------------------------------------------------
#
CREATE=1
DESTROY=1
RunHourly=1
RunDaily=1
RunWeekly=1
RunMonthly=1
while getopts 'crthHDWM' arg; do
	case $arg in
	c)
		CREATE=0
	;;
	d)
		DESTROY=0
	;;
	t)
		CREATE=0
		DESTROY=0
	;;
	H)
		RunHourly=0
	;;
	D)
		RunDaily=0
	;;
	W)
		RunWeekly=0
	;;
	M)
		RunMonthly=0
	;;
	h)
		echo "zfsnapper  Copyright (C) 2023
    This program comes with ABSOLUTELY NO WARRANTY; for details type \`show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type \`show c' for details."
		echo ""
		echo "Options: "
		echo " -c      Do not create snapshots"
		echo " -r      Do not destroy snapshots"
		echo " -t      Test only (do not create or destroy snapshots)"
		echo ""
		echo " -H      Disable hourly snapshot"
		echo " -D      Disable daily snapshot"
		echo " -W      Disable weekly snapshot"
		echo " -M      Disable monthly snapshot"
		echo ""
		exit 0
	;;
	*)
		echo "Unknown argument passed; exiting."
		exit 1
	;;
	esac
done

#
#-----------------------------------
# Run Main Program
#-----------------------------------
#
ReadAllSnapshots
GetDateVariables
SetSnapshotNames

if [ ${RunHourly} -eq 1 ]; then
	ProcessHourlySnapshots
fi
if [ ${RunDaily} -eq 1 ]; then
	ProcessDailySnapshots
fi
if [ ${RunWeekly} -eq 1 ]; then
	ProcessWeeklySnapshots
fi
if [ ${RunMonthly} -eq 1 ]; then
	ProcessMonthlySnapshots
fi
