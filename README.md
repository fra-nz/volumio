# 1 music library

- option a: copy mp3 files to volumio samba share `smb://<volumio-ip>/internal%20storage/`
- option b: copy mp3 files to volumio folder `/data/INTERNAL/`

# 2 fm4 / b2 on startup

## 2.1 create fm4 / b2 queue

- manually create queue in volumio containing single entry for fm4 / b2
- copy queue for use on startup:
    - `cp /data/queue /data/queue_fm4`
    - `cp /data/queue /data/queue_b2`

## 2.2 run startup script

- create startup script `startup.sh`
- make startup script executable with `chmod +x startup.sh`
- call startup script in `/etc/rc.local`

## 2.3 startup script

- activate ntp with `sudo timedatectl set-ntp True`
- set timezone with `sudo timedatectl set-timezone Europe/Berlin`
- sync time with ntp server:
```bash
    sudo systemctl stop ntp
    sudo ntpd -q -g
    sudo systemctl start ntp
```
- get day / time
  - `day=$(date +%u) # day of week (1..7); 1 is monday`
  - `time=$(date +%H:%M) # hour (00..23), minute (00..59)`
- replace queue based on date / time:
  - `cp /data/queue_b2 /data/queue`
  - `cp /data/queue_fm4 /data/queue`

## 2.4 activate autostart

- use volumio plugin AutoStart (1.1.2) to play the queue when volumio starts
