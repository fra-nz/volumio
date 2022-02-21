# setup volumio

- [setup volumio](#setup-volumio)
  - [install volumio](#install-volumio)
  - [configuration](#configuration)
  - [backup and restore (volumio 2 only)](#backup-and-restore-volumio-2-only)
    - [backup](#backup)
    - [restore](#restore)
  - [music library](#music-library)
- [autostart radio fm4 / b2](#autostart-radio-fm4--b2)
  - [create fm4 / b2 queue](#create-fm4--b2-queue)
  - [run startup script](#run-startup-script)
  - [startup script](#startup-script)
  - [activate autostart (volumio 2 only)](#activate-autostart-volumio-2-only)

## install volumio

- prepare sd card: https://volumio.com/en/get-started/
- enable ssh: https://volumio.github.io/docs/User_Manual/SSH.html

## configuration

- General Playback Options/Persistent Queue: On
- set timezone

```bash
cd /etc
rm localtime
ln -s /usr/share/zoneinfo/Europe/Berlin localtime
```

## backup and restore (volumio 2 only)

**WARNING**: Plugin "Backup & Restore" not yet supported for volumio 3!

- install plugin "Backup & Restore" to backup and restore configuration

### backup

- use plugin to create backup of the configuration (optional: also select playlist and favourites)
- backup `volumio_data.tgz` from volumio samba share `smb://<volumio-ip>/internal%20storage/`

### restore

- copy `volumio_data.tgz` to volumio samba share `smb://<volumio-ip>/internal%20storage/`
- restore configuration in plugin

## music library

- option a: copy mp3 files to volumio samba share `smb://<volumio-ip>/internal%20storage/`
- option b: copy mp3 files to volumio folder `/data/INTERNAL/`

# autostart radio fm4 / b2

## create fm4 / b2 queue

- manually create queue in volumio containing single entry for fm4 / b2
- copy queue for use on startup:
    - `cp /data/queue /data/queue_fm4`
    - `cp /data/queue /data/queue_b2`

## run startup script

- create startup script `startup.sh`
- make startup script executable with `chmod +x ./startup.sh`
- call startup script in `/etc/rc.local`

## startup script

- overwrite queue with default queue of fm4 and b2
- set volumestart.value in `/data/configuration/audio_interface/alsa_controller/config.json`
- wait and allow volumio to startup
- get day / time
  - URL: http://worldtimeapi.org/api/ip.txt
  - `day=$(date -d @${UNIXTIME} +%u) # day of week (1..7); 1 is monday`
  - `time=$(date -d @${UNIXTIME} +%H:%M) # hour (00..23), minute (00..59)`
- start playback:
  - set playback volume based on date / time
  - set fm4 or b2 based on date / time
  - start playback

## activate autostart (volumio 2 only)

**WARNING**: Plugin "Autoplay" not yet supported for volumio 3! Instead, the playback is started via
the command line interface in the startup script.

- install and activate volumio plugin "Autoplay" (1.0.0) to play the queue when volumio starts