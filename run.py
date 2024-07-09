import subprocess
from subprocess import Popen
import os
import signal
from pydantic import BaseModel
from datetime import datetime
from loguru import logger
from threading import Thread
from time import sleep


class ConnInfo(BaseModel):
    host: str
    port: int
    username: str
    password: str


def create_capture_command(conn_info: ConnInfo, filename: str) -> str:
    return f"gst-launch-1.0 -e rtspsrc location=rtsp://{conn_info.username}:{conn_info.password}@{conn_info.host}:{conn_info.port} name=src \
    src. ! rtph265depay ! h265parse name=vsrc \
    src. ! rtppcmadepay ! alawdec name=asrc \
    vsrc. ! matroskamux name=mux \
    asrc. ! mux. \
    mux. ! filesink location={filename}"


def create_display_command(conn_info: ConnInfo) -> str:
    rtsp_url = f"rtsp://{conn_info.username}:{conn_info.password}@{conn_info.host}:{conn_info.port}"

    command = [
        "gst-launch-1.0", "-e", f"rtspsrc location={rtsp_url} name=src", "src.",
        "!", "rtph265depay", "!", "avdec_h265", "!", "autovideosink", "src.",
        "!", "rtppcmadepay", "!", "alawdec", "!", "audioconvert", "!",
        "autoaudiosink"
    ]
    return " ".join(command)


def main():
    ps: list[Popen] = []
    g_flag = True
    conns = [
        ConnInfo(host="192.168.2.55",
                 port=554,
                 username="admin",
                 password="123456789a"),
        ConnInfo(host="192.168.2.57",
                 port=554,
                 username="admin",
                 password="123456789a"),
        ConnInfo(host="192.168.2.53",
                 port=554,
                 username="admin",
                 password="123456789a"),
        ConnInfo(host="192.168.2.52",
                 port=554,
                 username="admin",
                 password="123456789a"),
    ]

    def conn_to_filename(conn_info: ConnInfo) -> str:
        host_id = conn_info.host.split(".")[-1]
        now_str = datetime.now().isoformat().replace(":", "-")
        filename = f"{host_id}_{now_str}.mkv"
        return filename

    def conn_to_command(conn_info: ConnInfo) -> str:
        # return create_capture_command(conn_info, conn_to_filename(conn_info))
        return create_display_command(conn_info)

    def run_command(command: str):
        logger.info(f"Running command: {command}")
        p = Popen(command, shell=True)
        ps.append(p)

    for conn in conns:
        command = conn_to_command(conn)
        run_command(command)

    def handler(signum, frame):
        logger.info("Exiting...")
        nonlocal g_flag
        g_flag = False

    signal.signal(signal.SIGINT, handler)

    while g_flag:
        sleep(1)

    for p in ps:
        p.send_signal(signal.SIGINT)

    for p in ps:
        p.wait()

    logger.info("All processes are terminated.")


if __name__ == "__main__":
    main()
