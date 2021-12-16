
## Instructions for configuring OBS for greenscreen

# Install obs-studio
```
sudo apt install obs-studio
```

# Add v4l2loopback driver
```
sudo apt install v4l2loopback-dkms
```

# Create video device
```
sudo modprobe v4l2loopback video_nr=10 card_label="OBS Video Source" exclusive_caps=1
```

# Add v4l2sink
## Add prereqs
```
sudo apt install cmake qtbase5-dev
```

## Create a holding directory
```
mkdir myobscode
```

```
cd myobscode
```

## Clone the code for OBS Studio
```
git clone --recursive https://github.com/obsproject/obs-studio.git
```

## Clone the plugin code
```
git clone https://github.com/CatxFish/obs-v4l2sink
```

## Build the plugin
```
cd obs-v4l2sink
mkdir build && cd build
cmake -DLIBOBS_INCLUDE_DIR="../../obs-studio/libobs" -DCMAKE_INSTALL_PREFIX=/usr ..
make -j4
```

## Should install to `/usr/lib/obs-plugins/` 
```
sudo make install
```

# The rest is in OBS. Add the video source, add a filter if you have a greenscreen, add an image....boom