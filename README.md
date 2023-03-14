# Telemetry infrastructure 
The repo provided scalable Telemetry infrastructure references for both Docker (viadocker-compose) and Kubernetes (via Helm) approaches. User could select any of them or combined both approaches that suite the real scenario for deployment, each sub-component/service shall be able to communicate via exposed ip and port to each other regardless of deployment approach.

The recommended setup of this repo as below:
```
Node::Telegraf Node-> Node::OpenTelemetry Collector Agent-> Backend::OpenTelemetry Collector Gateway-> Backend::InfluxDB-> Backend::Grafana
```


## Deployment Order
Each sub-component/service, therefore,
1. InfluxDB
2. Open Telemetry Gateway
3. Open Telemetry Agent
4. Grafana


## How to connect Telemetry node to Telemetry Infra

```
[[outputs.opentelemetry]]
  service_address  = "192.168.1.107:4317"
```
