#!/bin/sh

sudo docker run -v /home/yockgen/jetson-inference/data/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
-v /home/yockgen/jetson-inference/data/result.txt:/result.txt \
telegraf
