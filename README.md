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
  
10. Labeling study for docker swarm
    - `ssh <kerberos>@buildroot.media.mit.edu`
    - `sudo docker node ls`
    - Grab unique identifier for machine
    - `docker node inspect <identifier>`
    - `docker node update --label-add study=s06 <identifier>`
    - Removing label: `docker node update --label-rm study=s06`



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

# Audrey's Instructions


## CREATING A MODEL NUC

  

1.  Connect NUC
	- USB with ubuntu18 installer (currently the green alligator drive. Yes, you can and probably should take its head off in order to connect it)
	-  Monitor, mouse, keyboard
	- Power cable LAST
2. Power on NUC (if plugging it in doesn’t automatically power it on)
3. Setup auto start when power plugged in
	- Press F2 instantly when powering on to enter BIOS Settings.
	- After entering BIOS settings, go to advanced > power > after power failure, select ‘power on’ instead of ‘stay off’.
	- Go to ‘Boot’ and disable ‘Secure Boot’ in UEFI boot option.
	-  Save and exit with F10.
4.  Install Ubuntu
	- When it asks to connect to wifi, connect manually to PRG’s wifi
	- Follow all default prompts, but when you get to the step where they ask where to install (replace existing installation, install alongside existing, erase disk), choose to erase the disk
	- When naming
		- Computer name: s06-n00-nuc-xxx for the model nuc (xxx gets replaced by specific numbers after cloning)
		- User Name: prg
		- Select “Login Automatically”
5. Clone the system setup repo
	- sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y git
	- git clone [https://github.com/mitmedialab/prg-s02-system-setup](https://github.com/mitmedialab/prg-s02-system-setup)
	- cd prg-s02-system-setup
	- git checkout s06-empathic-stories
6.  Run the install scripts
	- chmod +x s06-empathy-interactions/install_nuc_s06.sh
	- ./s06-empathy-interactions/install_nuc_s06.sh
	- Follow all prompts, including when it tells you to plug in a network adapter before wifi setup and when it prompts you to log into remotepc
7.  From station 165, transfer over the following files
	- ~/docker-compose.env from the home directory
	-  ~/.docker/config.json for the docker login (alternatively, if you know the docker login, you can just do that…I just don’t know the login so I always transfer the credential files lol)
8.  After rebooting, download the docker image manually
	- docker pull docker-registry.jibo.media.mit.edu:5000/s06-ros
	- This step will take a literal hour, if not more, so I would just step away when this starts
9.  At this point, you can create the clone image

## Creating a clone image of a model NUC

The directions will mostly follow this example from clonezilla: [https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/01_Save_disk_image](https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/01_Save_disk_image)

1. Both of the 32GB flash drives should have 2 partitions: 1 with clonezilla and 1 empty one in which the disk image will get saved (make sure its empty, otherwise, it won’t have enough space for the new clone…clone is ~19 GB)
    
2.  Power down ubuntu completely
	- sudo shutdown now
    
3.  Plug in one flash drive before you turn the nuc back on. Press and hold F10 as you turn on the nuc
    - You may have to manually select the clonezilla USB from the boot menu…usually it’s called “UEFI 5.00 something something: Part 1 something something”
  
4.  From this point on, follow the example instructions
	-  Pretty much everything should be the default option except for when they ask you to select the disk. This happens on the screen after you click “ctrl+c” when it’s listing the available devices. You won’t see the USB drive on that ctrl+c screen, but on the next one, the USB drive will likely be called something like “sda1/something something”. It is not either of the nvme0np1 partitions
  
5.  After you click through all of the default options, you should see something like this as the last confirmation:

![](https://lh6.googleusercontent.com/cdlOMhMGCkdW2iC-TCFUlrFWgFu54ORv-HQl_wDYjcMyv10v0kM2P2oN1wX39AO54qA4EFlFY_usTm8UuNRkjb4sj3k8I66qefJE9TTZEWwbHtxsb9ZzG9cYhKGn_MV0X5xyBDlwMH4_ErmILH_5gqA)
    


## Restoring a clone image of a model NUC

The directions will mostly follow this example from clonezilla: [https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/02_Restore_disk_image](https://clonezilla.org/show-live-doc-content.php?topic=clonezilla-live/doc/02_Restore_disk_image)

1.  Power down ubuntu (or existing operating system) completely
    - sudo shutdown now 

2.  Plug in one flash drive before you turn the nuc back on. Press and hold F10 as you turn on the nuc
	- You may have to manually select the clonezilla USB from the boot menu…usually it’s called “UEFI 5.00 something something: Part 1 something something”
4.  From this point on, follow the example instructions
    -   Pretty much everything should be the default option except for when they ask you to select the disk. This happens on the screen after you click “ctrl+c” when it’s listing the available devices. You won’t see the USB drive on that ctrl+c screen, but on the next one, the USB drive will likely be called something like “sda1/something something”. It is not either of the nvme0np1 partitions
    - When it asks you to select a directory, just select “Done” instead of the image folder listed (even though that will be the default directory). The directory it is asking for is the directory that contains the image folder (which will be the root directory of the USB). It will complain if you select the image folder directly
    
5.  After the image clone has been restored, select “poweroff” and after the nuc has completely shut down, remove the clonezilla USB
    
6.  Now we are mostly following these directions: [https://github.com/mitmedialab/prg-s02-system-setup#-installation-via-restoring-clone-image-guide-](https://github.com/mitmedialab/prg-s02-system-setup#-installation-via-restoring-clone-image-guide-)
    
7.  Connect the WiFi dongle and any external devices and power on the NUC. It should boot into the newly installed clone image
    
8.  Post cloning script
	-  cd ~/prg-s02-system-setup
	- git pull (you should be in the s06-empathic-stories branch)
	- chmod +x s06-empathy-interactions/post_clone_s06.sh
	- ./s06-empathy-interactions/post_clone_s06.sh <new-hostname, e.g., s02-n00-nuc-101>
   
9.  Set up remotepc
	- You will need to open up remotepc and rename the clone accordingly. It will bring up "this computer" to the top of the remote computer options and you should have the new hostname copied to clipboard at the end of the install script, so just rename "this computer" (current name should be "s06-n00-nuc-xxx_CLONE_bunchofletters") to the new hostname
    
10. From the home directory:
	- chmod +x prg-s02-system-setup/s06-empathy-interactions/docker_run_s06.sh
	- ./prg-s02-system-setup/s06-empathy-interactions/docker_run_s06.sh

11.  After ssh-ing into builtroot:
	-  sudo docker node ls (figure out the id number of the station you just added)
	-  sudo docker node update --label-add study=s06 idnumber


# Android Tablet

Refer to instructions here: [Samsung Tablet Preparation for KIOSK Mode](https://docs.google.com/document/d/1vAnE7qftmBP1pUEdUvw82mWBJK-IcUrL_qMNzCivffE/edit?usp=sharing)


# JIBO setup

1. (optional) Config jibo to auto restart at 7:15 in the morning (in case the memory full problem happened during the interaction.)
- `ssh` into the robot
- `jibo-mount --rw`
- `crontab -c /etc/crontabs -e`
- Add `15 7 * * *  /sbin/reboot` in the file
