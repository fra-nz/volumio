#!/bin/bash

# Create fresh log
echo "startup ..." > /data/startup.log

# Sync current date and time
sudo timedatectl set-ntp True
sudo timedatectl set-timezone Europe/Berlin

sudo systemctl stop ntp >> /data/startup.log
sudo ntpd -q -g >> /data/startup.log
sudo systemctl start ntp >> /data/startup.log

# Get current date and time
date >> /data/startup.log

day=$(date +%u) # day of week (1..7); 1 is monday
echo day:  $day >> /data/startup.log

time=$(date +%H:%M) # hour (00..23), minute (00..59)
echo time: $time >> /data/startup.log

# Replace current queue for autostart with queue only containing fm4 or b2
# based on the current day and time.
if [[ $day -ge 6 ]]
then
    echo "weekends -> fm4" >> /data/startup.log
    cp /data/queue_fm4 /data/queue
else
    if [[ "$time" < "08:30" || ("$time" > "11:30" && "$time" < "13:00") ]]
    then
        echo "workday early morning or noonish -> b2" >> /data/startup.log
        cp /data/queue_b2 /data/queue
    else
        echo "workday else -> fm4" >> /data/startup.log
        cp /data/queue_fm4 /data/queue
    fi
fi
