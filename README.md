# prg-s02-nuc-setup

# Intel NUC & Ubuntu

The following instruction assumes you have a bootable Ubuntu intallation USB thumbdrive.

1. Connect NUC.
    - Insert the intallation USB thumbdrive.
    - Connect monitor, mouse, and keyboard.
    - Connect power cable.

2. Power on NUC.

3. Setup auto start when power plugged in
    - Press F2 instantly when powering on to enter BIOS Settings. 
    - After entering BIOS settings, go to advanced > power > after power failure, select ‘power on’ instead of ‘stay off’. 
    - (optional) Go to ‘Boot’ and disable ‘Secure Boot’ in UEFI boot option.
    - Save and exit with F10.

4. Install Ubuntu. We use 16.04 LTS desktop image built for NUCs [http://people.canonical.com/~platform/images/nuc/pc-dawson-xenial-amd64-m4-20180507-32.iso?_ga=2.58458346.1505674856.1612557677-900696344.1612557677].
    - After a reboot, unplug the USB thumbdrive and connect the WiFi Adapter.
    - Settings
      - User Name: prg
      - Computer name:  as in the lable on the NUC, e.g., s02-n00-nuc-01
      - Password: (on LastPass)
      - Select Login Automatically.
    - Open System Settings -> Power and select "Don't suspend" under "Suspend when inactive" menu.
    - Open System Settings -> Software & Updates -> Updates and select "Never" under "Automatically check for updates", "Display immediately" under "When there are security updates", and "Never" under "Notify  me of a new Ubuntu version".
    - Open System Settings -> Brightness & Lock -> Turn screen off when inactive for “never”
 
5. Connect WiFi and Clone this repo.
    - `sudo apt update && sudo apt install -y git`
    - `git clone https://github.com/mitmedialab/prg-s02-system-setup`

6. Run the installation script.
    - `cd prg-s02-system-setup`
    - `./install_nuc.sh`
    - When prompted to select target environment, select 'HOME' for deployed stations and 'SCHOOL' for development stations. You can easily change this later.
    - When prompted for teamviewer configuration file setup, enter Y.
    - Enter y to setup the WiFi when prompted.
    - Do not reboot after WiFi setup. When prompted to reboot, enter n.
    - When prompted to setup USB camera, enter y. You can also skip and run `./setup_usb-cam.sh` later.

    - If prompted to update Ubuntu, do not.
    
    - (optional, skip this part for family study) USB_CAM docker container setup: the last part of the setup is configuring USB Camera Docker. Ctrl-C and exit if you don't know if you need this part.
    - (optional, only for family study) run additional installation scripts. 
        - `./teleop_station_setup.sh`
        - When prompted, setup realVNC (ID: robots.deployment@gmail.com, Pass: (on LastPass))
        - `cd family_setup. && ./family_extra_install.sh`

7. Setup RemotePC
    - run `remotepc &`
      - ID: robots.deployment@gmail.com
      - Password: (on LastPass, but also copied to clipboard at the end of the installation script)
    - reboot

8. Setup WiFi
    - After a reboot, navigate to http://10.99.0.1 on a web browser, and setup WiFi.
    * if the webpage only displays "Looking for Jibo Station...", then run `sudo ./add_wifi.sh`
      
9. Setup TeamViewer
    - `sudo teamviewer setup`
      - ID: robots.deployment@gmail.com
      - Password: (on LastPass)
    - **Check robots.deployment@gmail.com inbox to approve the NUC as trusted device.** If you don't do this, you won't be able to log in.
    - After approving via the link in the email, log in again.
    - Select 'y' to add the NUC to My Computer group.

10. Test
    - Test ssh into the new NUC from another machine on the same Network.
    - Test auto power on: unplug the power and replug to check if NUC auto powers on.


# Android Tablet

Refer to instructions here: [Samsung Tablet Preparation for KIOSK Mode](https://docs.google.com/document/d/1vAnE7qftmBP1pUEdUvw82mWBJK-IcUrL_qMNzCivffE/edit?usp=sharing)


# JIBO setup

1. (optional) Config jibo to auto restart at 7:15 in the morning (in case the memory full problem happened during the interaction.)
- `ssh` into the robot
- `jibo-mount --rw`
- `crontab -c /etc/crontabs -e`
- Add `15 7 * * *  /sbin/reboot` in the file
