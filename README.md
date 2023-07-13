# prg-s02-nuc-setup

# Intel NUC 

## == Installation via Restoring Clone Image Guide ==

(Skip steps 1-3 if you have access to a bootable clone image disk)
1. Download the clone image (image link placeholder).
2. Prepare a USB drive at least 16GB formatted with NTFS filesystem. 
    - Follow the guide for [creating a bootable Clonezilla Live disk](https://clonezilla.org/clonezilla-live.php) 
    - If you're creating it on ubuntu, mount the USB drive and run
       `unzip <clone-image.zip> -d <USB-drive-mount-path>`
       
3. On a new NUC, connect the bootable USB drive. Power up.
4. The NUC should automatically boot into Clonezilla and execute "Hae Won's S02 Recipe" fully unattended to restore the image on to the new NUC's SSD. It takes around 10 minutes, go grab a drink.
5. When restoring is completed, select "Poweroff". Wait till the NUC is completely powered down.

6. Unmount the USB drive. 
    - **Connect WiFi dongle.**
    - **Connect Webcam.**
    - Power on the NUC.

7. Boot into the BIOS menu by pressing F2.
    - Change the UEFI boot order so that `ubuntu` is above SAMSUNG...(In `Boot > Boot Priority`)
    - Go to Advanced > Power > After power failure, select `power on` instead of ‘stay off’. (In `Power > Secondary Power Settings > After power failure`)
    - Go to `Boot` and disable `Secure Boot` in UEFI boot option.
    - Save and exit with F10.
    - NUC will now boot into Ubuntu.

8. Post cloning tasks
    - If you forgot to plug in the WiFi dongle or the webcam, do so and reboot before the next steps.
    - Open terminal and run...
        ```
        cd ~/prg-s02-system-setup
        git pull
        ./post-clone.sh <new-hostname, e.g., s02-n00-nuc-101>
        ```
    - The script will first change the hostname (check message reporting successful).
    - Next, it will join docker swarm and prompt you to select which swarm to join. 
    - Lastly, it will install RemotePC and Teamviewer. Follow the instructions on the screen.
        - Open a new terminal window and setup RemotePC. 
            - `remotepc &`
            - It will prompt you to accept the terms. Accept.
            - Login. Credentials are on LastPass, and the password is copied to the clipboard, so simply CTRL-V. 
        - Setup Teamviewer
            - `sudo teamviewer setup`
            - 'n' to located in Korea, 'y' to accept terms.
            - Login. Credentials are on LastPass
                - After the first login, robots.deployment@gmail.com will receive a link to add the device as trusted. Click the link and accept.
            - Re-login. 'y' to add the device to "My Computers" list.
     
9. All done. Verify the followings work correctly...
    - VPN: [http://rover.jibo.media.mit.edu:1967](http://rover.jibo.media.mit.edu:1967)
    - Docker Swarm: [http://prg-webhost.media.mit.edu:8889](http://prg-webhost.media.mit.edu:8889)
    - RemotePC and Teamviewer

## == Full Manual Installation Guide ==

The following instruction assumes you have a bootable Ubuntu intallation USB thumbdrive. We use 16.04 LTS desktop image built for NUCs [http://people.canonical.com/~platform/images/nuc/pc-dawson-xenial-amd64-m4-20180507-32.iso?_ga=2.58458346.1505674856.1612557677-900696344.1612557677].

1. Connect NUC.
    - Insert the intallation USB thumbdrive.
    - Connect monitor, mouse, and keyboard.
    - Connect power cable.

2. Power on NUC.

3. Setup auto start when power plugged in
    - Press F2 instantly when powering on to enter BIOS Settings. 
    - After entering BIOS settings, go to advanced > power > after power failure, select ‘power on’ instead of ‘stay off’. 
    - Go to ‘Boot’ and disable ‘Secure Boot’ in UEFI boot option.
    - Save and exit with F10.

4. Install Ubuntu. 
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
    - Pulseaudio and loopback for nuc-10s
        - Make sure `load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket` is added to `/etc/pulse/default.pa` in local ubuntu.
        - Also, add the followings to `/etc/pulse/client.config` 
          ```
          default-server = unix:/tmp/pulseaudio.socket 
          autospawn = no 
          daemon-binary = /bin/true 
          enable-shm = false
          ``` 
        - add `options v4l2loopback video_nr=7,8 card_label="family project","family project 2"` to `/etc/modprobe.d/v4l2loopback.conf`
        - To activate/deactivate loopback, open a browser and enter `http://localhost/loopback/on` or `http://localhost/loopback/off`. Please refer to dyadic-controller.py in auto-dyadic-controller for doing it with python requests.
        - `systemctl stop jibo-station-wifi-service.service`
         

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

11. For the empathy interaction clones: make sure that the docker-compose.env has been copied into the /home/prg directory


# Android Tablet

Refer to instructions here: [Samsung Tablet Preparation for KIOSK Mode](https://docs.google.com/document/d/1vAnE7qftmBP1pUEdUvw82mWBJK-IcUrL_qMNzCivffE/edit?usp=sharing)


# JIBO setup

1. (optional) Config jibo to auto restart at 7:15 in the morning (in case the memory full problem happened during the interaction.)
- `ssh` into the robot
- `jibo-mount --rw`
- `crontab -c /etc/crontabs -e`
- Add `15 7 * * *  /sbin/reboot` in the file
