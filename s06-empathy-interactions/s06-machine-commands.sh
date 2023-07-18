#!/bin/bash

read -r -d '' jons_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6TTbm/ufNLpLZweMkQscLiMo1TkpBurKIsmJw59jQTyYdcVAiUbWmE2KjdhVCRb4OPbq+4j+GL6bsCelEIJUKJYwiprFskV9POFYd+1Rivuge4POl3o9dSp1xQ5mSCf4UhGryIbX/avqom2SRUWQG8Rqn/cw7IjwE/GW0FFAWLtXkk2aesIZQwYpO4WgbDLdb/wEY/7d3ws+dK2/YwlcbRDnkAG3xq5Bj27Y4KxD6O83E+oyoTL1Yc7B5jJD3KG60Tp7UwsiCEkjuGWCP6t7wVMJuUPXonyjhsbtAp2c/tXw6JrTCAWNFCQZIGUkp0Hfe8UXLrnych8bmv8e0/q0z jon@Jons-13inch-MacBook-Pro.local
EOF

read -r -d '' haewons_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHTDAMP5W03vgYNfdTuaO7GPiNKJ/+Mq+/QpxO5Sv9kuEbbem54PpJSZXtjdMONYbiRLD5h60BEyxPL+NL32nRZVvGZAPo2+xVcwA5Wqk2r1csDhltk5Tuo7aq6QXu5xnmlmsnQBUCgMbimwkXGf1gun9pjsPaU5MHfYRdi2njSmTT8BcYQ8UvifsbRqyQUYAAQOQay638vFUefjrhqQg50/LoKlbC3fWbWpkUFI8lWxQXsWzIOjjN12sW+AC7c9pfRcN0Eft/A+uARipfDCrUjIeAZWp+Co3UjrGhPcM1IhqqQIgiqfZDTxN5E7M6AbN8CNfMMP8lycZ2GIRt8YdYXVL06dhyXYZaaay3xVvlVw2JlS+PdieREMIVX15BVqRlrTrADE2lBH53tDwv1IpG+g3Wl4llX3aorO8hI8fTXgcnBwzgVkId/CMmn8CEG7bBnKY1WZDpzfMzL9sS7soKIsJVtmSLwrC0nXtEXRU27y6sncFKRIhdZs5eBUkBInQKhOMM/NGDLAyT+b0lgVeuNdZTukRF8vIvVG8QcGppVxd80Uk6HIT0P7xe7X7BmEQUVGxrK5EESmzQe4/+WUyrqXXfzVw7QJQiDPXcRNPFcZ6W4X+2Jw0M+Wgu6UnKVyYiiWaUJ1RsrfWbo/MYLOXXpqsYmNEs5tAVi0VZ9LQ40Q== haewon@media.mit.edu
EOF

read -r -d '' jocelyns_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNhyG7+qUJ91E+6c4YZ8//jFcLxQWrEpRLSHQPS9jJLJc2tLgymkef0KCVxh1epXbJxFf57PLzAlXnx0JV/O5HWND1IHwXP165NsxnKtoUWCyC80eI/Vy31Wfi6JBKtrVqUnpFEFZhQ8MiXWNxU5ywEgXKypnDLH9jt2l7NUB0BvjQxZbREudRv2Eaou78MBIzkmzj2BruvLGggsQqXEpeL6tKI9IWBAeK6k+RmyUwKqmynABbdxGh80kcts6/mAGAYI/gVmn2ZUkAchpOyXetx47ou8mYoQynzpVgaEt5J5Cb9hFpPZ8I3EwlakuX7RLZDzibONEE1gQfsWqI7KZt Brayden@zhangxiajiedeMacBook-Pro.local
EOF

read -r -d '' audreys_ssh_key <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTFAA43eenaFwVesQ+WCo8e++u9LhBkPNpSlFRrWMwrwnbzE84DI7JooPM1x3l8g+POY7lzFkB+XyaDOkdTF/qChWMM4rh1V10MEVUAFvP4zPEnIUqOspoXbAwRMH6SVGMiL0sFIJwZ/hrdQdRCZwTdSmURUFAnKBLMx0jfUuEyXNjRy2DIJ6Wg2OUE85WkpNp2+zsNWwvHoZ7nDxHa/cIK9NKaGAw+91tcrvXFQ9DUcX68oX4BR0apsYJJ1iUQHfI6UdCGo8V/wObVS8tI5rHPuhIo3+Ud5oy9G5mWGzxqwHuaHKk08/jRlTnG6Fav5vwsC+p0uKznoRmhkS6HjVntYC6fs7RIcRlRqO5dVI2I0RjpiKwEfxcSjq5/xQzy8hg9mPilQF6xCTZWEJ3W5+c+7DFQJF8IjgkfYpOq9g+NDWxmzFdNtLvjcj0tcUAMRbpPxLs5/c3l/uAD99xrn8E4r4wpf60a6LHruzlx8Kj0+ekPrAsYkrUbSintCdw3oAt5v61viv926/l1pZL839+GH9lL0BmwxHrvq4LVqrw08uCvXkJLZYXs8/Y9ipojcV9pvZ67yas+dZjX3Vl98KLmVTyQ5xcRd0PxEdrgjxD2+WoZ2OFK6pOkIIsIupsJIAT3aKalB9BcdMqlmB1z/fkgd4xdNZM8mP0MMOp5fW2IQ== audrey16@mit.edu
EOF


install_prg_ssh_keys() {
    echo "adding haewon's ssh key"
    echo "$haewons_ssh_key" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr
    echo "adding brayden's ssh key"
    echo "$jocelyns_ssh_key" > /tmp/additional_key.pub
    ssh_cmd ssh-copy-id -f -i /tmp/additional_key $username@$nuc_ip_addr
    echo "adding sam's ssh key"
    echo "$audreys_ssh_key" > /tmp/additional_key.pub
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


