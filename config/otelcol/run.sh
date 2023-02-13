#!/bin/bash

rm /data/temp/otel_db.json
sudo service otelcol stop
otelcol-contrib --config=file:/etc/otelcol/config.yaml
