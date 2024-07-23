$TGT_HOST="192.168.2.221"
$TGT_PORT=554
$USERNAME="admin"
$PASSWORD="123456789a"

gst-launch-1.0 -e \
    rtspsrc location=rtsp://${USERNAME}:${PASSWORD}@${TGT_HOST}:${TGT_PORT} name=src `
    src. ! `
        rtph265depay ! `
        h265parse name=vsrc `
    src. ! `
        rtppcmadepay ! `
        alawdec name=asrc `
    vsrc. ! `
        matroskamux name=mux `
    asrc. ! `
        mux. `
    mux. ! `
        filesink location=record-$NOW.mkv

# https://gstreamer.freedesktop.org/documentation/libav/avenc_aac.html?gi-language=c
# note that it's for H.265 video and G.711A audio
