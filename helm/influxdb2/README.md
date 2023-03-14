## InfluxDB Helm Chart Official Guide
[https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md](https://github.com/influxdata/helm-charts/blob/master/charts/influxdb2/README.md)

## Make InfluxDB2 Charts available in Helm 
```
helm repo add influxdata https://helm.influxdata.com/
helm repo update
```
## Cleanup
```
helm uninstall intel-influxdb2
```

## InfluxDB Helm Installation examples

### Deployment without persistent storage - data wiped out after restart
```
helm install \
-f /data/otel/helm/influxdb2/values.yaml \
--set persistence.enabled=false \
--set adminUser.organization="intel" \
--set adminUser.bucket="intel" \
--set adminUser.token="X6zYQsXQdkC4K-WE7Uza_Z7yYWkENe3PAbNPIjryr4_KECA75QoLqALgsX9XQjWMFhdhZFz1TiLjxYUiM7B1zw==" \
--set adminUser.user="admin" \
--set adminUser.password="intel@2023" \
intel-influxdb2 influxdata/influxdb2
```
