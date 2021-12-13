#!/usr/bin/env bash

# Exit on any non-zero exit codes
# set -e

#install obs-studio
sudo apt install obs-studio
#add v4l2loopback driver
sudo apt install v4l2loopback-dkms
#create video device
sudo modprobe v4l2loopback video_nr=10 card_label="OBS Video Source" exclusive_caps=1

#add v4l2sink
#add prereqs
sudo apt install cmake qtbase5-dev

#Create a holding directory
mkdir myobscode
cd myobscode
