#!/bin/bash
rm /data/temp/otel_db.json
otelcol-contrib --config=file:/etc/otelcol/config.yaml
