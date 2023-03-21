#!/bin/sh
result=$(timeout 3s intel_gpu_top -l | awk 'END{print}')
render=$(echo $result | awk 'END{print $9}')
blitter=$(echo $result | awk 'END{print $12}')
video=$(echo $result | awk 'END{print $15}')
videoEnh=$(echo $result | awk 'END{print $18}')

echo "{\"render3d\": ${render}, \"blitter\": ${blitter}, \"video\": ${video}, \"video_enhance\": ${videoEnh}}"
