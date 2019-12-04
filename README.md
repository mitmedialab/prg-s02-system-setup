# prg-s02-nuc-setup

# Intel NUC & Ubuntu

The following instruction assumes you have a bootable Ubuntu intallation USB thumbdrive.

1. Insert the intalltion USB thumbdrive.

2. Power on NUC.

3. Auto start when power plugged in
  - Press F2 instantly when powered on Intel Nuc. After entering BIOS settings, go to advanced > power > after power failure, select ‘power on’ instead of ‘stay off’. 
  - Save and exit with F10.

4. Install Ubuntu. We use 16.04 LTS desktop image built for NUCs.
- Settings
  - User Name: prg
  - Computer name:  as in the sticker, e.g., s02-n01-nuc-01
  - Password: (ask Hae Won)
  - Check Login automatically 

5. Run the installation script.
- `./install_nuc.sh`
  -You will get prompted to login to our Docker account:
  -ID: mitprg
  -Pass: (in group doc)

- If prompted for update Ubuntu, do not.
- Test ssh to the now installed NUC from another machine int he same Network.

# Android Tablet

1. App permission. For face id app, iSpy app, etc. Make sure all of them have permission to Storage and Camera.
2. Download the Scalefusion app and register your device with a license from the web browser console. Apply device profile to your device (also from the web browser console).
3. USB debugging. Open the tablet and enable developer mode + allow USB debugging


# JIBO setup

1. Config jibo to auto restart at 3 in the morning (in case the memory full problem happened during the interaction.)
- `ssh` into the robot
- `jibo-mount --rw`
- `crontab -c /etc/crontabs -e`
- Add `0 3 * * *  /sbin/reboot` in the file
