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


## install volumio

- prepare sd card: https://volumio.com/en/get-started/
- enable ssh: https://help.volumio.com/help/how-do-i-enable-ssh-connection


## configuration

- General Playback Options/Persistent Queue: On
- set timezone

```bash
cd /etc
rm localtime
ln -s /usr/share/zoneinfo/Europe/Berlin localtime
```


## backup and restore (volumio 2 only)

- install plugin "Backup & Restore" to backup and restore configuration

### backup

- use plugin to create backup of the configuration (optional: also select playlist and favorites)
- backup `volumio_data.tgz` from volumio samba share `smb://<volumio-ip>/internal%20storage/`

### restore

- copy `volumio_data.tgz` to volumio samba share `smb://<volumio-ip>/internal%20storage/`
- restore configuration in plugin


## music library

- option a: copy mp3 files to volumio samba share `smb://<volumio-ip>/internal%20storage/`
- option b: copy mp3 files to volumio folder `/data/INTERNAL/`


# autostart radio fm4 / b2

## create fm4 / b2 queue

- manually create queue in volumio containing single entry for fm4 and b2
- copy queue for use on startup: `cp /data/queue /data/queue_fm4_b2`


## run startup script

- create startup script `startup.sh`
- make startup script executable with `chmod +x ./startup.sh`
- call startup script in `/etc/rc.local`


## startup script

- overwrite queue with `queue_fm4_b2`
- set volumestart.value to `disabled` in `/data/configuration/audio_interface/alsa_controller/config.json`
- set mixer.value to `PCM` in `/data/configuration/audio_interface/alsa_controller/config.json`
- wait and allow volumio to startup
- get day / time
- start playback:
  - set playback volume based on date / time
  - select fm4 or b2 based on date / time
  - start playback
