$TGT_HOST="192.168.2.221"
$TGT_PORT=554
$USERNAME="admin"
$PASSWORD="123456789a"
# d3d11h265dec
# nvh265dec
$H265DEC="nvh265dec"

# note that it's for H.265 video and G.711A audio

gst-launch-1.0 -e `
    rtspsrc location=rtsp://${USERNAME}:${PASSWORD}@${TGT_HOST}:${TGT_PORT} name=src `
    src. ! `
    rtph265depay ! `
    ${H265DEC} ! `
    autovideosink `
    src. ! `
    rtppcmadepay ! `
    alawdec ! `
    audioconvert ! `
    autoaudiosink


