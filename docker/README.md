Backend - InfluxDB
```
cd /data/otel/docker/influxdb
docker-compose up
```

Backend - Grafana
```
cd /data/otel/docker/grafana
docker-compose up
```

Backend - OTELCOL gateway example
```
cd /data/otel/docker/otel 
CONFIG=/data/otel/docker/otel/config-backend-gateway-demo-server.yaml docker-compose up
```

Node - OTELCOL agent example
```
cd /data/otel/docker/otel 
CONFIG=/data/otel/docker/otel/config-edge-agent.yaml docker-compose up
```

Node - Telegraf

```
telegraf --config telgraf-config.conf
```
