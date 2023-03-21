#!/bin/sh
result=$(timeout 3s intel_gpu_top -l | awk 'END{print}')
ttl=$(echo $result | awk '{print NF}')

if [ $ttl -ge 23 ] #intel-gpu-tools 1.26 onward version
then
  render=$(echo $result | awk 'END{print $9}')
  blitter=$(echo $result | awk 'END{print $12}')
  video=$(echo $result | awk 'END{print $15}')
  videoEnh=$(echo $result | awk 'END{print $21}')
else
  render=$(echo $result | awk 'END{print $8}')
  blitter=$(echo $result | awk 'END{print $11}')
  video=$(echo $result | awk 'END{print $14}')
  videoEnh=$(echo $result | awk 'END{print $17}')
fi

echo "{\"render3d\": ${render}, \"blitter\": ${blitter}, \"video\": ${video}, \"video_enhance\": ${videoEnh}}"
