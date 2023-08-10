#!/bin/bash

if [[ ! -e ./docker-compose.env ]]; then
    echo "run this in the home directory (where docker-compose.env should be saved)"
    exit 1
fi

# Add stuff to script about checking the microphone and setting pacmd set-source-volume to 100%

echo -e "Setting microphone volumes (both AC-44 and AC-404) to 100%"
echo -e "If you get one 'no such entity' error, this is because both microphones are being configured, but you should only have one plugged in."
echo -e "You can ignore one 'no such entity error', but not two. If you get two, check to make sure that a microphone is plugged in"
echo
pactl set-source-volume "alsa_input.usb-MXL_MXL_AC-44-00.analog-mono" 100%
pactl set-source-volume "alsa_input.usb-Burr-Brown_from_TI_USB_audio_CODEC-00.analog-mono" 100%
echo

echo -e "Clearing old device containers"
echo -e "You can ignore any errors; it just means that the containers weren't running already"
docker stop s06-microphone s06-camera
docker container prune --force --filter "label=device_container"

docker image pull docker-registry.jibo.media.mit.edu:5000/s06-ros

echo -e "Running microphone container"
docker run --env-file docker-compose.env -d -it --name=s06-microphone --label="device_container" --ipc="host" --device=/dev/snd -v /etc/asound.conf:/etc/asound.conf --restart=always --network=host docker-registry.jibo.media.mit.edu:5000/s06-ros:latest /bin/bash -c "sudo /etc/init.d/alsa-utils restart; sudo chown -R :prg /dev; cd ../asr_assembly/src; python3.8 local_mic_asr.py"

echo -e "Running USB camera container"
docker run --env-file docker-compose.env -d -it --name=s06-camera --label="device_container" --ipc="host" --device=/dev/snd --device=/dev/video0 -v /etc/asound.conf:/etc/asound.conf -v /home/prg/s06-empathy-interaction/empathy_videos:/home/prg/s06-empathy-interaction/empathy_videos --restart=always --network=host docker-registry.jibo.media.mit.edu:5000/s06-ros:latest /bin/bash -c "sudo /etc/init.d/alsa-utils restart; sudo chown -R :prg /dev; sudo chown -R :prg /home/prg/s06-empathy-interaction; cd ../usb_cam; python3.8 usb_cam_cmd.py"

if ! egrep -q docker_run_s06.sh /etc/rc.local; then
    if [[ $(tail -1 /etc/rc.local) = "exit 0" ]]; then
        NEW_RC_LOCAL="$(head -n -1 /etc/rc.local; echo '(cd /home/prg && ./prg-s02-system-setup/s06-empathy-interactions/docker_run_s06.sh)'; echo 'exit 0')"
        echo "$NEW_RC_LOCAL" | sudo tee /etc/rc.local >/dev/null
    else
        echo "Error: /etc/rc.local doesn't end with 'exit 0' line"
    fi
fi
