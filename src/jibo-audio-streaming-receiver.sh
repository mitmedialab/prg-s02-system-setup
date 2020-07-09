#!/bin/sh

bluetooth=false
port=5555
caps="application/x-rtp,channels=(int)1,format=(string)S16LE,media=(string) audio,payload=(int)96,clock-rate=(int)48000,encoding-name=(string)L24"

while true; do

    if [ "$bluetooth" = true ]; then
      gst-launch-1.0 -v udpsrc port=$port caps="$caps" ! rtpL24depay ! audioconvert ! volume volume=1.0 ! pulsesink device=bluez_sink.E3_67_22_BD_D3_BC

    else
      gst-launch-1.0 -v udpsrc port=$port caps="$caps" ! rtpL24depay ! audioconvert ! volume volume=1.0 ! alsasink sync=false
    fi

    echo "gst-launch-1.0 exited, restarting it!"
    sleep 1
done
