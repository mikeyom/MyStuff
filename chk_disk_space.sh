#!/bin/bash
# All Rights Reserved.
# $Author: Mike Yom<mikeyom@gmail.com>
# Nagios plugin script checks disk space 

# Nagios return codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

rm -f /tmp/nagios_*.txt
if [ $? = 1 ]; then
   echo "The script ran as root before need to delete /tmp/nagios_*.txt"
   exit 1
fi

df -Ph > /tmp/nagios_disk.txt

# Skipping first line
cat /tmp/nagios_disk.txt | grep -v Filesystem | grep -v /var/c2/shared | grep -v /var/c2/code/care2 | grep -v /mnt/care2 > /tmp/nagios_new_disk.txt

# Checking eachline to see if disk percentage is over 90% full
while read line
do
  echo $line > /tmp/nagios_disk_text.txt

  CHK_DISK=`cat /tmp/nagios_disk_text.txt | awk '{print $5}'| cut -d% -f1`

# Some filesystem name is long than it will list in two lines.
  if ! [ "$CHK_DISK" == "" ]; then

# If first line is empty the 2nd line is where disk percentage is listed
    if ! [[ "$CHK_DISK" =~ ^[0-9]+$ ]]; then
       CHK_DISK=`cat /tmp/nagios_disk_text.txt | awk '{print $4}'| cut -d% -f1`
    fi

# Setting Nagios exit code of 2 critical if disk percentage is over 95% full
    if [ $CHK_DISK -gt 95 ]; then
       echo "Critical `cat /tmp/nagios_disk_text.txt | awk '{print $1 "\t" $5 " disk full\t" $6}'`"
       exit $STATE_CRITICAL
    fi

# Setting Nagios exit code of 1 warning if disk percentage is over 90% full
    if [ $CHK_DISK -gt 90 ]; then
       echo "Warning `cat /tmp/nagios_disk_text.txt | awk '{print $1 "\t" $5 " disk full\t" $6}'`"
       exit $STATE_WARNING
    fi
  fi
done < /tmp/nagios_new_disk.txt

if [ $CHK_DISK -le 90 ]; then
   LARGE_FILE=`sort -k5 -n /tmp/nagios_new_disk.txt | tail -n 1`
   echo "File system is OK. Largest file system is $LARGE_FILE"
fi
