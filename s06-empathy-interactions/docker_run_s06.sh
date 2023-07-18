#!/bin/bash

echo -e "Running microphone container"
docker run --env-file docker-compose.env -d -it --name=s06-microphone --ipc="host" --device=/dev/snd -v /etc/asound.conf:/etc/asound.conf --restart=always --network=host docker-registry.jibo.media.mit.edu:5000/s06-ros /bin/bash -c "sudo /etc/init.d/alsa-utils restart; sudo chown -R :prg /dev; cd ../asr_assembly/src; python3.8 local_mic_asr.py"

echo -e "Running USB camera container"
docker run --env-file docker-compose.env -d -it --name=s06-camera --ipc="host" --device=/dev/snd --device=/dev/video0 -v /etc/asound.conf:/etc/asound.conf -v /home/prg/s06-empathy-interaction/empathy_videos:/home/prg/s06-empathy-interaction/empathy_videos --restart=always --network=host docker-registry.jibo.media.mit.edu:5000/s06-ros /bin/bash -c "sudo /etc/init.d/alsa-utils restart; sudo chown -R :prg /dev; sudo chown -R :prg /home/prg/s06-empathy-interaction; cd ../usb_cam; python3.8 usb_cam_cmd.py"