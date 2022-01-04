#!/usr/bin/env bash

# Script location
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source all of our helper scripts
source $SCRIPT_DIR/functions.sh

printf "Installing liquidctl \n"

install_package("liquidctl")

printf "Creating liquidcfg.service file \n"

echo "[Unit]
Description=AIO startup service

[Service]
Type=oneshot
ExecStart=liquidctl initialize all
ExecStart=liquidctl --match kraken set pump speed 90
ExecStart=liquidctl --match kraken set ring color fading \"hsv(0,100,100)\" \"hsv(120,100,100)\" \"hsv(300,100,100)\"

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/liquidcfg.service


printf "Reloading systemctl and starting/enabling the service \n"
sudo systemctl daemon-reload
sudo systemctl start liquidcfg.service
sudo systemctl enable liquidcfg.service


printf "Below should be some stats on your Kraken device, look for 90% pump duty cycle to indicate the script worked \n"
liquidctl status

printf "All done! Your Kraken should now be fading through the rainbow (and your CPU temp should drop)!"