HOST=192.168.2.55
PORT=554
USER_NAME=admin
PASSWORD=123456789a
NOW=$(date +"%Y%m%d-%H%M%S")

# export GST_DEBUG=4

gst-launch-1.0 -e \
    rtspsrc location=rtsp://$USER_NAME:$PASSWORD@$HOST:$PORT name=src \
    src. ! \
        rtph265depay ! \
        h265parse name=vsrc \
    src. ! \
        rtppcmadepay ! \
        alawdec name=asrc \
    vsrc. ! \
        matroskamux name=mux \
    asrc. ! \
        mux. \
    mux. ! \
        filesink location=record-$NOW.mkv

# https://gstreamer.freedesktop.org/documentation/libav/avenc_aac.html?gi-language=c
# note that it's for H.265 video and G.711A audio
