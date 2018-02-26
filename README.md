# Camera stream receiver

Create totally 4 virtual video devices: 
```
# modprobe v4l2loopback devices=4 exclusive_caps=0
```

Testing stream to /dev/video2:
```
$ gst-launch-1.0 videotestsrc ! tee ! v4l2sink device=/dev/video2
```

STDIN as source for WebM audio/video source and screen display:
```
$ gst-launch-1.0 fdsrc fd=0 ! queue ! matroskademux name=d d.video_0 ! vp8dec ! videoconvert ! autovideosink
```

STDIN as source for JPEG encoded video as source for /dev/video2:
```
$ gst-launch-1.0 -vvv fdsrc fd=0 ! queue ! jpegdec ! videoconvert ! videoscale ! tee ! v4l2sink device=/dev/video2
```

UDP port 9000 as source for JPEG encoded video for /dev/video2:
```
$ gst-launch-1.0 -vvv udpsrc port=9000 ! queue ! jpegdec ! videoconvert ! videoscale ! tee ! v4l2sink device=/dev/video2
```