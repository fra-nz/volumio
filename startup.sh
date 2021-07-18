#!/bin/bash

# Define module-global logfile
LOG_FILE="/data/startup.log"

# Function to set the volume via the volumio command in order to update UI:
# $1: Volume level
function fix_volume_ui {
    VOLUME=$1

    echo "fix volume ui -> ${VOLUME}" >> ${LOG_FILE}

    volumio volume ${VOLUME}
}

# Function to set the startup volume in the corresponding config file:
# $1: Startup volume level
function set_startup_volume {
    VOLUME=$1

    local CONFIG_FILE="/data/configuration/audio_interface/alsa_controller/config.json"
    local CONFIG_TMP_FILE="/data/configuration/audio_interface/alsa_controller/config.json.tmp"

    echo "startup volume -> ${VOLUME}" >> ${LOG_FILE}

    jq ".volumestart.value = \"${VOLUME}\"" ${CONFIG_FILE} > ${CONFIG_TMP_FILE} && mv ${CONFIG_TMP_FILE} ${CONFIG_FILE}

    # WORKAROUND: additionally set volume after a delay via volumio command to update UI
    sleep 30 && fix_volume_ui ${VOLUME} &
}

# Create fresh log
echo "startup ..." > ${LOG_FILE}

# Sync current date and time
sudo timedatectl set-ntp True
sudo timedatectl set-timezone Europe/Berlin

sudo systemctl stop ntp >> ${LOG_FILE}
sudo ntpd -q -g >> ${LOG_FILE}
sudo systemctl start ntp >> ${LOG_FILE}

# Get current date and time
date >> ${LOG_FILE}

day=$(date +%u) # day of week (1..7); 1 is monday
echo day:  $day >> ${LOG_FILE}

time=$(date +%H:%M) # hour (00..23), minute (00..59)
echo time: $time >> ${LOG_FILE}

# Set autostart queue and volume
# Based on the current day and time replace current queue with pre-defined queue (fm4 or b2) and set
# adjusted volume level.
if [[ $day -ge 6 ]]
then

    echo "weekends -> fm4" >> ${LOG_FILE}
    cp /data/queue_fm4 /data/queue
    set_startup_volume 60

else
    if [[ "$time" < "08:30" ]]
    then

        echo "workday early morning -> b2" >> ${LOG_FILE}
        cp /data/queue_b2 /data/queue
        set_startup_volume 70

    elif [[ "$time" > "11:30" && "$time" < "13:00" ]]
    then

        echo "workday noonish -> b2" >> ${LOG_FILE}
        cp /data/queue_b2 /data/queue
        set_startup_volume 90

    else

        echo "workday else -> fm4" >> ${LOG_FILE}
        cp /data/queue_fm4 /data/queue
        set_startup_volume 60

    fi
fi
