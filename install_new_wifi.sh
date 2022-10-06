# Refresh the Repository
sudo apt update

# Install the pieces
sudo apt install -y git binutils gcc dkms make

# Install the Kernel Bits needed
sudo apt install -y build-essential libelf-dev linux-headers-`uname -r`

# Go to your Downloads
cd ~/Downloads

# Clone the Specific Version of the Repository
git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git

# Let's Visit the Directory the driver source-code we just cloned
cd rtl*

# Build the Code
make

# Need Admin Permissions to Start Install
sudo make install
