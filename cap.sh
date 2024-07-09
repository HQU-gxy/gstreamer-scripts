HOST=192.168.2.221
PORT=554
USERNAME=admin
PASSWORD=123456789a
gst-launch-1.0 -e \
    rtspsrc location=rtsp://$USERNAME:$PASSWORD@$HOST:$PORT name=src \
    src. ! \
    rtph265depay ! \
    avdec_h265 ! \
    autovideosink \
    src. ! \
    rtppcmadepay ! \
    alawdec ! \
    audioconvert ! \
    autoaudiosink

# note that it's for H.265 video and G.711A audio
