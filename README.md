# 1 music library

- option a: copy mp3 files to volumio samba share `smb://<volumio-ip>/internal%20storage/`
- option b: copy mp3 files to volumio folder `/data/INTERNAL/`

# 2 fm4 / b2 on startup

## 2.1 create fm4 / b2 queue

- manually create queue in volumio containing single entry for fm4 / b2
- copy queue for use on startup:
    - `cp /data/queue /data/queue_fm4`
    - `cp /data/queue /data/queue_b2`

## 2.2 replace queue on login

- add following lines to `/etc/rc.local`:

```bash
    #!/bin/bash

    # ...

    # Replace current queue for autostart with queue only containing fm4 or b2 based on the current day and time.

    day=$(date +%u) # day of week (1..7); 1 is monday

    if [[ $day -ge 6 ]]
    then
        # weekends -> fm4
        cp /data/queue_fm4 /data/queue
    else
        # workdays -> check time
        time=$(date +%H:%M) # hour (00..23), minute (00..59)

        if [[ "$time" < "08:30" || ("$time" > "11:30" && "$time" < "13:00") ]]
        then
            # early morning or noonish -> b2
            cp /data/queue_b2 /data/queue
        else
            # else -> fm4
            cp /data/queue_fm4 /data/queue
        fi
    fi
```

## 2.3 activate autostart

- use volumio plugin AutoStart (1.1.2) to play the queue when volumio starts
