$TGT_HOST="192.168.2.221"
$TGT_PORT=554
$USERNAME="admin"
$PASSWORD="123456789a"
# d3d11h265dec
# nvh265dec
$H265DEC="nvh265dec"

# https://gstreamer.freedesktop.org/documentation/libav/avenc_aac.html?gi-language=c

gst-launch-1.0 -e `
    rtspsrc location=rtsp://${USERNAME}:${PASSWORD}@${TGT_HOST}:${TGT_PORT} name=src `
    src. ! `
        rtph265depay ! `
        h265parse ! tee name=vsrc ! queue ! matroskamux name=mux `
    src. ! `
        rtppcmadepay ! `
        alawdec ! tee name=asrc ! queue ! mux. `
    mux. ! `
        filesink location=record-$NOW.mkv `
    vsrc. ! `
        queue ! `
        ${H265DEC} ! `
        videoconvert ! `
        autovideosink `
    asrc. ! `
        queue ! `
        audioconvert ! `
        autoaudiosink

