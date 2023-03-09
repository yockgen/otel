## Grafana Helm Chart Official Guide
https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md

## Make Grafana Charts available in Helm 
```
helm uninstall intel-grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Configuring InfluxDB connection
1. Downloaded this repo, preferred stored under /data parent directory 
2. Configuring InfluxDB connection in values.yaml
```
cd /data/otel/helm/grafana
nano +525 values.yaml
```

Configured accordingly to target InfluxDB, exaple:
```
## Configure grafana datasources
## ref: http://docs.grafana.org/administration/provisioning/#datasources
##
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Intel_Influx
        type: influxdb
        access: proxy
        url: http://192.168.1.107:8086
        jsonData:
          version: Flux
          organization: intel
          defaultBucket: intel
          tlsSkipVerify: true
        secureJsonData:
          token: {influxdb token for access}
```



## Example Helm Installation

### Deployment without persistent storage - data wiped out after restart
```
helm install \
-f /data/otel/helm/grafana/values.yaml \
--set adminPassword="admin" \
--set persistence.enabled=false \
--set persistence.storageClassName="manual" \
--set-file dashboards.default.power-insight-01.json=/data/otel/helm/grafana/dashboards/power-insight.json \
--set-file dashboards.default.intel-demo.json=/data/otel/helm/grafana/dashboards/intel-demo.json \
intel-grafana grafana/grafana
```


### Deployment with persistent storage

#### Pre - Cleanup - ensure environment is clean before deployment
```
cd /data/otel/helm/grafana
helm uninstall intel-grafana
kubectl delete -f persistent.yaml
```
#### Pre - Re-create persistent storage 
```
kubectl apply -f persistent.yaml
```

#### Sample deployment 01
```
helm install \
-f /data/otel/helm/grafana/values.yaml \
--set adminPassword="admin" \
--set persistence.enabled=true \
--set persistence.storageClassName="manual" \
intel-grafana grafana/grafana
```
#### Sample deployment 02 - import dashboard during deployment
```
helm install \
-f /data/otel/helm/grafana/values.yaml \
--set adminPassword="admin" \
--set persistence.enabled=true \
--set persistence.storageClassName="manual" \
--set-file dashboards.default.power-insight-01.json=/data/otel/helm/grafana/dashboards/power-insight.json \
intel-grafana grafana/grafana
```