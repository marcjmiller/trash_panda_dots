## Instructions for configuring OBS for greenscreen
### Sourced from https://www.eigenmagic.com/2020/04/22/how-to-use-obs-studio-with-zoom/

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

# The rest is in OBS. Add the video source, add a filter if you have a greenscreen, add an image....boom