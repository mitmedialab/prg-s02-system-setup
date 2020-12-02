# prg-s02-nuc-setup

# Intel NUC & Ubuntu

The following instruction assumes you have a bootable Ubuntu intallation USB thumbdrive.

1. Connect NUC.
    - Insert the intallation USB thumbdrive.
    - Connect monitor, mouse, and keyboard.
    - **Connect WiFi Dongle** (optional)
    - Prepare PRG-MIT network.
    - Connect power cable.

2. Power on NUC.

3. Auto start when power plugged in
    - Press F2 instantly when powered on Intel Nuc. 
    - After entering BIOS settings, go to advanced > power > after power failure, select ‘power on’ instead of ‘stay off’. 
    - Save and exit with F10.

4. Install Ubuntu. We use 16.04 LTS desktop image built for NUCs.
    - Settings
      - User Name: prg
      - Computer name:  as in the lable on the NUC, e.g., s02-n01-nuc-01
      - Password: (on LastPass)
      - Select Login Automatically.
    - Connect to PRG-MIT wifi.
    - Open System Settings -> Power and select "Don't suspend" under "Suspend when inactive" menu.
 
5. Clone this repo.
    - `sudo apt install -y git`
    - `git clone https://github.com/mitmedialab/prg-s02-system-setup`

6. Run the installation script.
    - `cd prg-s02-system-setup`
    - `./install_nuc.sh`
    - If prompted for teamviewer configuration file setup, enter Y.
    - If prompted for update Ubuntu, do not.
    - Check for errors, but don't worry about the error about unable to find /dev/video0 when starting USB_CAM docker container.

7. Setup RemotePC
    - run `remotepc`
        - ID: robots.deployment@gmail.com
      - Password: (on LastPass)
      
8. Setup TeamViewer
    - `sudo teamviewer setup`
      - ID: robots.deployment@gmail.com
      - Password: (on LastPass)
    - **Don't forget to check email to add the NUC as trusted device.** If you don't do this, you won't be able to log in.
    - Given an option, select 'y' to add the NUC to the account.

9. Test
    - Test ssh into the new NUC from another machine on the same Network.
    - Test auto power on: unplug the power and replug to check if NUC auto powers on.


# Android Tablet

1. App permission. For face id app, iSpy app, etc. Make sure all of them have permission to Storage and Camera.
2. Download the Scalefusion app and register your device with a license from the web browser console. Apply device profile to your device (also from the web browser console).
3. USB debugging. Open the tablet and enable developer mode + allow USB debugging


# JIBO setup

1. Config jibo to auto restart at 7:15 in the morning (in case the memory full problem happened during the interaction.)
- `ssh` into the robot
- `jibo-mount --rw`
- `crontab -c /etc/crontabs -e`
- Add `15 7 * * *  /sbin/reboot` in the file
