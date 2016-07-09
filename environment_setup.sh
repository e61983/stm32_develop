#!/bin/bash
# @file environment_setup.sh
# @brief Set develop environment
# @author Hua-Yuan
# @date 2016-07-09

# Update APT Repositories
sudo apt-get update

# Check Git is installed

sudo apt-get install git-core make -y

# Install basic develop tool
sudo apt-get install gcc-arm-none-eabi gdb-arm-none-eabi -y
sudo apt-get install automake* pkg-config libtool libusb-1.0-0-dev -y

# Install ST-link
git clone http://github.com/texane/stlink.git
cd stlink
./autogen.sh
./configure --pre=/usr
make
sudo make install
sudo cp 49-stlinkv2.rules /etc/udev/rules.d/
cd ..

# Install OpenOCD
sudo apt-get install texi2html texinfo -y
git clone git://git.code.sf.net/p/openocd/code openocd
cd openocd
./bootstrap
./configure --prefix=/usr --enable-stlink
make
sudo make install
