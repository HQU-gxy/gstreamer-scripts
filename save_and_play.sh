HOST=192.168.2.55
PORT=554
USER_NAME=admin
PASSWORD=123456789a
NOW=$(date +"%Y%m%d-%H%M%S")

# https://gstreamer.freedesktop.org/documentation/tutorials/playback/hardware-accelerated-video-decoding.html?gi-language=c
# export GST_DEBUG=4

gst-launch-1.0 -e \
    rtspsrc location=rtsp://$USER_NAME:$PASSWORD@$HOST:$PORT name=src \
    src. ! \
        rtph265depay ! \
        h265parse ! tee name=vsrc ! queue ! matroskamux name=mux \
    src. ! \
        rtppcmadepay ! \
        alawdec ! tee name=asrc ! queue ! mux. \
    mux. ! \
        filesink location=record-$NOW.mkv \
    vsrc. ! \
        queue ! \
        avdec_h265 ! \
        videoconvert ! \
        autovideosink \
    asrc. ! \
        queue ! \
        audioconvert ! \
        autoaudiosink

# https://gstreamer.freedesktop.org/documentation/libav/avenc_aac.html?gi-language=c
# note that it's for H.265 video and G.711A audio
