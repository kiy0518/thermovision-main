#!/bin/bash
echo "Setting up udev rules for FLIR Lepton/PureThermal..."
echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e4e", ATTRS{idProduct}=="0100", SYMLINK+="pt1", GROUP="usb", MODE="666"' > 99-pt1.rules
sudo mv 99-pt1.rules /etc/udev/rules.d/99-pt1.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
echo "Success! Udev rules installed."
echo "Please unplug and replug your camera now."
