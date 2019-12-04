#!/bin/bash

username="prg"
password="kronik420"
wifi_password="JiboLovesPizzaAndMacaroni1"
jibo_audio_file="jibo-audio-streaming-receiver.sh"


n02_addr=(
"10.111.28.49"
"10.111.28.50"
"10.111.28.51"
"10.111.28.52"
)

# execute an ssh command, but handle the continue connection prompt and/or the password prompt
ssh_cmd() {
    expect -f - $password $* <<EOF
        # jibo-bbfw-update can take a few minutes, set the timeout to handle that
        set timeout 600
	#exp_internal 1  # make expect more verbose

        set password [lindex \$argv 0]
        set cmd [lindex \$argv 1]
        set args [lrange \$argv 2 end]

	log_user 0   # make expect less verbose
        eval spawn -noecho \$cmd \$args
        expect {
            "continue connecting (yes/no)? " {
                send "yes\r"
		exp_continue
            }            
            "password: " {
                send "\$password\r"
		exp_continue
	    }
	    eof {
	        catch wait result
		exit [lindex \$result 3]
	    }
        }
EOF
}

ssh_nuc() {
    ssh $username@$nuc_ip_addr $*
}

ssh_nuc_sudo() {
    ssh -t $username@$nuc_ip_addr $*
}


setup_jibo_audio_streaming() {

  ssh_cmd scp $jibo_audio_file $username@$nuc_ip_addr:~/jibo-audio-streaming-receiver.sh
  ssh_nuc_sudo "echo $password | sudo -S mv ~/jibo-audio-streaming-receiver.sh  /usr/local/bin/"
  #ssh_nuc_sudo "sudo chmod a+x /usr/local/bin/jibo-audio-streaming-receiver.sh"
  if ssh_nuc grep -q "$jibo_audio_file" /etc/rc.local; then
    echo "jibo audio streaming is already setup."
  else
    ssh_nuc_sudo "echo $password | sudo -S sed -i '/exit 0/i\/usr/local/bin/jibo-audio-streaming-receiver.sh &\n' /etc/rc.local"
  fi
}



read -r -d '' jons_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6TTbm/ufNLpLZweMkQscLiMo1TkpBurKIsmJw59jQTyYdcVAiUbWmE2KjdhVCRb4OPbq+4j+GL6bsCelEIJUKJYwiprFskV9POFYd+1Rivuge4POl3o9dSp1xQ5mSCf4UhGryIbX/avqom2SRUWQG8Rqn/cw7IjwE/GW0FFAWLtXkk2aesIZQwYpO4WgbDLdb/wEY/7d3ws+dK2/YwlcbRDnkAG3xq5Bj27Y4KxD6O83E+oyoTL1Yc7B5jJD3KG60Tp7UwsiCEkjuGWCP6t7wVMJuUPXonyjhsbtAp2c/tXw6JrTCAWNFCQZIGUkp0Hfe8UXLrnych8bmv8e0/q0z jon@Jons-13inch-MacBook-Pro.local
EOF

read -r -d '' haewons_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHTDAMP5W03vgYNfdTuaO7GPiNKJ/+Mq+/QpxO5Sv9kuEbbem54PpJSZXtjdMONYbiRLD5h60BEyxPL+NL32nRZVvGZAPo2+xVcwA5Wqk2r1csDhltk5Tuo7aq6QXu5xnmlmsnQBUCgMbimwkXGf1gun9pjsPaU5MHfYRdi2njSmTT8BcYQ8UvifsbRqyQUYAAQOQay638vFUefjrhqQg50/LoKlbC3fWbWpkUFI8lWxQXsWzIOjjN12sW+AC7c9pfRcN0Eft/A+uARipfDCrUjIeAZWp+Co3UjrGhPcM1IhqqQIgiqfZDTxN5E7M6AbN8CNfMMP8lycZ2GIRt8YdYXVL06dhyXYZaaay3xVvlVw2JlS+PdieREMIVX15BVqRlrTrADE2lBH53tDwv1IpG+g3Wl4llX3aorO8hI8fTXgcnBwzgVkId/CMmn8CEG7bBnKY1WZDpzfMzL9sS7soKIsJVtmSLwrC0nXtEXRU27y6sncFKRIhdZs5eBUkBInQKhOMM/NGDLAyT+b0lgVeuNdZTukRF8vIvVG8QcGppVxd80Uk6HIT0P7xe7X7BmEQUVGxrK5EESmzQe4/+WUyrqXXfzVw7QJQiDPXcRNPFcZ6W4X+2Jw0M+Wgu6UnKVyYiiWaUJ1RsrfWbo/MYLOXXpqsYmNEs5tAVi0VZ9LQ40Q== haewon@media.mit.edu
EOF

read -r -d '' braydens_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNhyG7+qUJ91E+6c4YZ8//jFcLxQWrEpRLSHQPS9jJLJc2tLgymkef0KCVxh1epXbJxFf57PLzAlXnx0JV/O5HWND1IHwXP165NsxnKtoUWCyC80eI/Vy31Wfi6JBKtrVqUnpFEFZhQ8MiXWNxU5ywEgXKypnDLH9jt2l7NUB0BvjQxZbREudRv2Eaou78MBIzkmzj2BruvLGggsQqXEpeL6tKI9IWBAeK6k+RmyUwKqmynABbdxGh80kcts6/mAGAYI/gVmn2ZUkAchpOyXetx47ou8mYoQynzpVgaEt5J5Cb9hFpPZ8I3EwlakuX7RLZDzibONEE1gQfsWqI7KZt Brayden@zhangxiajiedeMacBook-Pro.local
EOF

read -r -d '' sams_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbYlJR/Xfi3UJyHZl2k+Fn17XigvUQjpMr/sFvfI9mKrc1iCTEnedN2afeyP/vR2Iri+Yg8S6jp3fyb5ACZM9z4pbpbfJfokzPq2KDIDCM8g8SjBpJsmPJ17zG+OiRmmmQ+Rs7Uop5dAnL7/s4hc+yzQ6HaRz1//vEOkzuIM4ymLoWM/so0xIhgc0XgW8vRyF2ZYU+YkM7K8n3PH4/Z7uBph0oYqD3NgsFuFnAeeI5Id4lUodv+/i/xcrcPwcoxyalAXU2ytzICK/6CM3CzKG5Bd5nKs4hmyMCIU0EZzFc99ifbtPlJmUvSbf7KATKKZwVhIpdSfVz6J3Bu8WmId4alUNhoBgbcObZeSUlMcFn7JsFyaX7A0y5MYA2YJT7kNF/7362c0HQLUyUEay9i7cRBaMRkiHu/gJV1w3MCHoIkBMr5qgjGcLC9KzFthF56FL1WMOjS7Aq9dfzmagLY3UaOR4ji8DaYbbC5//SDHHXC2iNwgEVp+Y63YzvHApLmNVrdpKma2fLWZuJ+PzEcmLhEyTytxb0Me4j/59XIZJAztmcB9fk0lCGrha+MxMuvt0cJ3ROUnBLeC0t+AQq+nLN4/s2dd+H2k/J2l2nwAK82pRk0eAhpSDZQM0GjJ0szpe9/n9b2u1L7WFyocpIXOeRc2f6KR0zqhrsTdqz3Xsj5w== samuelsp@mit.edu
EOF


setup_wifi() {
  echo
  echo "Setting up WiFi $required_ssid"
  FILE=/etc/NetworkManager/system-connections/"$required_ssid"
  if ssh_nuc test -f "$FILE"; then
    echo "    $required_ssid exists. Skipping.."
  else
    echo "add"
    #ssh_nuc iwconfig wlan0 essid $required_ssid key 
  fi
}

ping_test() {
    ping -i 0.2 -c 1 -t 1 -q $1 >/dev/null
}


wait_for_jibo_on_network() {
    if ping_test $1; then
    echo "i see the jibo"
    else
	echo "please plug jibo into your laptop with the ethernet cable"
	while ! ping_test $1; do
	    echo -n "."
	done
	echo ""
	echo "thank you! i see him now"
    fi
}


reboot_for_phase_2() {
    echo "rebooting for phase 2"
    ssh_nuc reboot
    echo "waiting for jibo to shutdown..."
    while ping_test $1; do
	echo -n "."
	sleep 1
    done
    echo ""
    sleep 5
    echo "waiting for jibo to reboot..."
    while ! ping_test $1; do
	echo -n "."
    done
    echo ""
    echo "i can see jibo again. waiting for the dev-shell service to start..."
    while ! nc -z $nuc_ip_addr $dev_shell_port; do
	echo -n "."
	sleep 1
    done
    echo ""
    sleep 5
}


remove_ssh_known_host() {
    ssh-keygen -R $1
}


install_prg_ssh_keys() {
    echo "adding haewon's ssh key"
    echo "$haewons_ssh_key" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr
    echo "adding brayden's ssh key"
    echo "$braydens_ssh_key" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr
    echo "adding sam's ssh key"
    echo "$sams_ssh_key" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr
    echo "adding jon's ssh key"
    echo "$jons_ssh_key" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr

}     


install_additional_ssh_key() {
    echo "$1" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr
}


set_password() {
    expect -f - $* <<EOF
    	set user [lindex \$argv 0]
        set newpassword [lindex \$argv 1]

	log_user 0   # make expect less verbose
        eval spawn -noecho ssh $username@$nuc_ip_addr "passwd" \$user
        expect {
            "New password:" {
                send "\$newpassword\r"
		exp_continue
            }            
            "Retype password:" {
                send "\$newpassword\r"
		exp_continue
	    }
	    eof {
	        catch wait result
		exit [lindex \$result 3]
	    }
        }
EOF
}


set_root_and_skill_passwords() {
    echo "setting root and jibo-skill passwords"
    set_password root $1
    set_password jibo-skill $1
}

ask_to_place_face_down() {
    read -p "place the robot face down and press return: " line
}


ask_to_reboot_jibo() {
    read -p "reboot jibo [y]? " yn
    case $yn in
	""|[yY]|yes|Yes|YES )
	    ssh_nuc reboot
	    ;;
	* )
	    echo "not rebooting"
	    ;;
    esac
}

for i in ${!n02_addr[@]}; do
  nuc_ip_addr=${n02_addr[$i]}
  echo $i, $nuc_ip_addr
  #install_prg_ssh_keys
  #ssh_nuc ls 
  #required_ssid="PRG-MIT-8"
  #setup_wifi
  setup_jibo_audio_streaming
done

