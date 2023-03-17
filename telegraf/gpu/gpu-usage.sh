#!/bin/sh

#count=$(timeout 3s intel_gpu_top -l -o temp.json)
#result=$(cat ./temp.json | awk 'END{print $9}')
result=$(timeout 3s intel_gpu_top -l | awk 'END{print $9}')
echo $result
