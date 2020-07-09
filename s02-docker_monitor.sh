#!/bin/bash
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

launch_log_window(){
    while :
    do
	dID=`docker ps -qf "name=^$1" 2>/dev/null`
	dName=`echo $1 | cut -f2 -d"_"`
        xterm -geometry 65x20+$2+$3 -T $dName -e bash -c "docker logs -f $dID"
	sleep 1s
    done
}

launch_exec_window(){
    while :
    do
	dID=`docker ps -qf "name=^$1" 2>/dev/null`
	dName=`echo $1 | cut -f2 -d"_"`
        xterm -geometry 65x20+$2+$3 -e bash -c "docker exec -it $dID /ros_catkin_entrypoint.sh $4"
	sleep 1s
    done
}

ids=`docker ps -qf "name=^s02-ros"`

#echo $ids

let x=75; let y=0

for id in $ids
do
    name=`docker inspect --format="{{.Name}}" $id | cut -f1 -d"."`
    #name=`docker inspect --format="{{.Name}}" $id | cut -f1 -d"." | cut -f2 -d"_"`
    echo $id $name
    launch_log_window $name $x $y&
    if [[ $x -gt 800 ]]; then
        let x=75; let y=$y+350
    else
    	let x=$x+420
    fi
    if [[ $name == "/s02-ros_usb-cam" ]]; then
	echo "launch hz"
        launch_exec_window $name $x $y "rostopic hz /usb_cam/image_raw/compressed"&
        launch_exec_window $name $x $y "rostopic hz /affect_detection"&
        launch_exec_window $name $x $y "rostopic hz /affdex_auto_detection"&
        if [[ $x -gt 800 ]]; then
            let x=75; let y=$y+350
        else
    	    let x=$x+420
        fi
    fi
        
done

echo "Ctrl-C to quit"
read y
