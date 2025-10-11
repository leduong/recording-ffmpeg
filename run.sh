#!/bin/bash
while true; do
  if ! pgrep -f "/home/ffmpeg/recording" > /dev/null; then
    echo "Process not found, starting recording-ffmpeg server..."
    nohup /home/ffmpeg/recording 2>&1 &
    sleep 10
  fi
  sleep 20
done
