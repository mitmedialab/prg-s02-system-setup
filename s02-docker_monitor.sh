#!/bin/bash
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

launch_log_window(){
    while :
    do
          xterm -geometry 65x20+$3+$4 -T $1 -e bash -c "docker logs -f $2"
    done
}

ids=`docker ps -qf "name=^s02-ros"`

#echo $ids

let x=75; let y=0

for id in $ids
do
    name=`docker inspect --format="{{.Name}}" $id | cut -f1 -d"." | cut -f2 -d"_"`
    echo $id $name
    launch_log_window $name $id $x $y&
    if [[ $x -gt 800 ]]; then
        let x=75; let y=$y+350
    else
    	let x=$x+420
    fi
done

echo "Ctrl-C to quit"
read year
