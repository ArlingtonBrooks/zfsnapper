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
