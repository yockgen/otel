# Telemetry infrastructure 
The repo provided scalable Telemetry infrastructure references for both Docker (viadocker-compose) and Kubernetes (via Helm) approaches. User could select any of them or combined both approaches that suite the real scenario for deployment, each sub-component/service shall be able to communicate via exposed ip and port to each other regardless of deployment approach.

The recommended setup of this repo as below:
```
Node::Telegraf Node-> Node::OpenTelemetry Collector Agent-> Backend::OpenTelemetry Collector Gateway-> Backend::InfluxDB-> Backend::Grafana
```


## Deployment Order
Some sub-components/services have interdependencies, therefore, recommended to deploy them according to order below:
1. InfluxDB
   - Helm solution: [./helm/influxdb2](./helm/influxdb2) 
   - Docker solution: [./docker/influxdb](./docker/influxdb)
2. Open Telemetry Gateway (using gateway profile)
   - Helm solution: [./helm/otelcol](./helm/otelcol)
   - Docker solution: [./docker/otel](./docker/otel)
3. Open Telemetry Agent (using agent profile)
   - Helm solution: [./helm/otelcol](./helm/otelcol)
   - Docker solution: [./docker/otel](./docker/otel)
4. Grafana
   - Helm solution: [./helm/grafana](./helm/grafana)
   - Docker solution: [./docker/grafana](./docker/grafana)

Please read README in each respective directory for technical guidance.

## Default port number exposed in each services
Service | Helm (via Kubernetes Node Port) | Docker-Compose
--- | --- | ---
*InfluxDB* | **http://{any cluster node ip}:32701** | **http://{host ip}:58100**
*Grafana* | **http://{any cluster node ip}:32601** | **http://{host ip}:59500**
*OpenTelemetry Gateway* | **http://{any cluster node ip}:31082** | **http://{host ip}:52199**
*OpenTelemetry Agent* | **http://{any cluster node ip}:30695** | **http://{host ip}:52199**


## How to connect Telemetry node to Telemetry Infra

```
[[outputs.opentelemetry]]
  service_address  = "192.168.1.107:30695"
```
