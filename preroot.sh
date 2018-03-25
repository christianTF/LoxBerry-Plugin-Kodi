#!/bin/bash
# Will be executed as user "root".

echo "<INFO> Installing pipplware Kodi repository"
echo "<INFO> Copying kodi.list to /etc/apt/sources.list.d/"
echo "Temporary directory of plugin installation is $6"
cp -f "$6/data/kodi.list" /etc/apt/sources.list.d/
echo "<INFO> Adding repo key to apt trusted keys"
wget -O - http://pipplware.pplware.pt/pipplware/key.asc | apt-key add - 


# # We have to default raspiBackup to not zip, as we cannot override this for rsync backups (will fail)
# #	sed -i.bak 's/^\(DEFAULT_ZIP_BACKUP=\).*/\1"0"/' $lbbackupconfig 

# # Create backup directory if missing
# if [ ! -d "/backup" ]; then
	# echo "<INFO> Creating default /backup directory"
	# mkdir -p /backup
	# chown loxberry:loxberry /backup 
# fi

# if [ -e "$LBHOMEDIR/system/cron/cron.d/$2" ]; then
	# chown root:root $LBHOMEDIR/system/cron/cron.d/$2
# fi

exit 0
