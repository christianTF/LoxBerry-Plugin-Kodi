#!/bin/bash
# Will be executed as user "root".

# echo "<INFO> Installing raspiBackup"

# # Install raspiBackup
# chmod +x REPLACELBPDATADIR/raspiBackupInstall.sh
# bash REPLACELBPDATADIR/raspiBackupInstall.sh -c

# chmod +x $5/data/plugins/$3/raspiBackup*.sh
# mv -u -f $5/data/plugins/$3/raspiBackup_*.sh /usr/local/bin/


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

# Add loxberry user to groups
echo "<INFO> Adding loxberry to groups audio, video, input, dialout, plugdev, tty"
usermod -a -G audio loxberry
usermod -a -G video loxberry
usermod -a -G input loxberry
usermod -a -G dialout loxberry
usermod -a -G plugdev loxberry
usermod -a -G tty loxberry

# Install Kodi as a service
echo "<INFO> Copy init.d startup script"
cp -f data/kodi /etc/init.d/kodi
chmod +x /etc/init.d/kodi
echo "<INFO> Install Kodi to run automatically at startup"
systemctl enable kodi

echo "<INFO> Setting GPU memory to 192MB in config.txt"
awk -v s="gpu_mem=192" '/^gpu_mem=/{$0=s;f=1} {a[++n]=$0} END{if(!f)a[++n]=s;for(i=1;i<=n;i++)print a[i]>ARGV[1]}' /boot/config.txt

exit 0
