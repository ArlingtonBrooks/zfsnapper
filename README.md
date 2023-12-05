# zfsnapper
ZFS Filesystem Automatic Snapshot Script

# Installing
This is just a bash script.  You can install this into your `cron.hourly` directory, or on a systemd timer to run automatically every hour.  

# Usage
This is meant to be run in a daemon; however, if you wish to run it from the command line, the following options exist: 

		-c      Do not create snapshots (prints warnings)
		-r      Do not destroy snapshots (prints warnings)
		-t      Test only (do not create or destroy snapshots; prints warnings)
		-H      Disable hourly snapshot
		-D      Disable daily snapshot
		-W      Disable weekly snapshot
		-M      Disable monthly snapshot

# Parameters
This code does not read a configuration file; instead, the configuration is simply stored in the header of the file.  
The variables which can be tuned are in the top of the configuration file.  

# Snapshot Retention
Rather than storing based on time, snapshots are stored based on number of snapshots.  This prevents, for example, loss of snapshots due to a power outage which lasts multiple days; in such a case, rather than detecting a bunch of >24 hour old snapshots and deleting them, zfsnapper just starts creating new snapshots as if those older snapshots were recent.  The idea here is to keep so many hourly, daily, weekly, and monthly snapshots regardless of their age so at any time the only snapshots which are at risk are the oldest in each category.  
