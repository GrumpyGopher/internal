#!/bin/sh
# HELP: Clear SFTPGO Keys
# ICON: clear

# This script will remove the SFTPGO keys
# These will be (re)generated on next boot.

FRONTEND stop

SFTP_DIR="/opt/sftpgo"

echo "Deleting SFTPGO Keys"
rm -f "${SFTP_DIR:?}"/id_*

echo "Sync Filesystem"
sync

echo "All Done!"
echo "Please reboot your device."
/opt/muos/bin/toybox sleep 5

FRONTEND start task
exit 0