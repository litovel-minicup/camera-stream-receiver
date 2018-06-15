#!/usr/bin/env bash

UDP_PORT=${2:-9000};

DEVICES=$(ls /dev/video* |  grep -v "video[012]" | sort);

if [ "$1" != "" ]; then
	DEV="/dev/video$2";
else
	for device in ${DEVICES};
	do
		fuser $device 2&>1 >/dev/null || {
			DEV=$device;
			break;
		};
	done
fi

PORT_OFFSET=$(echo "$DEV" | sed -e 's/\/dev\/video//g');
if [ "$DEV" == "" ]; then
	echo "No empty virtual video device, aborting.";
	echo "Try extend devices by:";
	echo "# modprobe v4l2loopback devices=N exclusive_caps=0.";
	exit;
fi
PORT=$(expr "${UDP_PORT}" + "${PORT_OFFSET}");

echo "Transmitting from 0.0.0.0:$PORT to $DEV.";
echo "========================================";

gst-launch-1.0 -vvv \
	udpsrc port=${PORT} ! \
	queue ! \
	h264parse ! \
	avdec_h264 ! \
	videoconvert ! \
	tee ! \
	queue ! \
	v4l2sink sync=false device=${DEV};
