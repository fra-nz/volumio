#!/bin/bash

# Create fresh log file
LOG_FILE="/data/startup.log"
echo "startup ..." > ${LOG_FILE}

# Function to set the startup options in the corresponding config file:
function set_startup_options {
    VOLUME=disabled
    MIXER=PCM

    local CONFIG_FILE="/data/configuration/audio_interface/alsa_controller/config.json"
    local CONFIG_TMP_FILE="/data/configuration/audio_interface/alsa_controller/config.json.tmp"

    echo "set startup volume -> ${VOLUME}" >> ${LOG_FILE}
    jq ".volumestart.value = \"${VOLUME}\"" ${CONFIG_FILE} > ${CONFIG_TMP_FILE} && mv ${CONFIG_TMP_FILE} ${CONFIG_FILE}

    echo "set mixer control name -> ${MIXER}" >> ${LOG_FILE}
    jq ".mixer.value = \"${MIXER}\"" ${CONFIG_FILE} > ${CONFIG_TMP_FILE} && mv ${CONFIG_TMP_FILE} ${CONFIG_FILE}
}

# Function to select sender in queue, set the volume and start playback via the volumio command:
# $1: Sender {FM4, B2}
# $1: Volume level
function start_playback {
    SENDER=$1
    VOLUME=$2

    echo "start playback of ${SENDER} with volume ${VOLUME}" >> ${LOG_FILE}

    volumio volume ${VOLUME}

    if [[ "${SENDER}" == "FM4" ]]
    then

        # first title in queue is already selected, nothing to do
        :

    elif [[ "${SENDER}" == "B2" ]]
    then

        # select second title in queue
        volumio next

    else

        echo "Error: Sender is not B2 or FM4." >> ${LOG_FILE}

    fi

    volumio play
}

# Set startup options in configuration
set_startup_options
# Overwrite queue
cp /data/queue_fm4_b2 /data/queue

# Let volumio start up
sleep 20

# Get current date and time
echo "date: $(date)" >> ${LOG_FILE}

day=$(date +%u) # day of week (1..7); 1 is monday
echo day:  $day >> ${LOG_FILE}

time=$(date +%H:%M) # hour (00..23), minute (00..59)
echo time: $time >> ${LOG_FILE}

# Set sender and volume based on the current day and time
if [[ $day -ge 6 ]]
then

    SENDER="FM4"
    VOLUME=60
    echo "weekends -> ${SENDER}, ${VOLUME}" >> ${LOG_FILE}

else
    if [[ "$time" > "06:00" && "$time" < "08:30" ]]
    then

        SENDER="B2"
        VOLUME=70
        echo "workday early morning -> ${SENDER}, ${VOLUME}" >> ${LOG_FILE}

    elif [[ "$time" > "11:30" && "$time" < "13:00" ]]
    then

        SENDER="B2"
        VOLUME=90
        echo "workday noonish -> ${SENDER}, ${VOLUME}" >> ${LOG_FILE}

    else

        SENDER="FM4"
        VOLUME=60
        echo "workday else -> ${SENDER}, ${VOLUME}" >> ${LOG_FILE}

    fi
fi

# Start playback via volumio command
start_playback ${SENDER} ${VOLUME}
