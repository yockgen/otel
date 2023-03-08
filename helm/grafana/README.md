## Grafana Official Guide
https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md

## Make Grafana Charts available in Helm 
```
helm uninstall intel-grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Create persistent storage if persistence.enabled=true on next step
```
cd /data/otel/helm/grafana
kubectl delete -f persistent.yaml
kubectl apply -f persistent.yaml
```

## Example Helm Installation

### Pre - Cleanup - ensure environment is clean before deployment
```
cd /data/otel/helm/grafana
helm uninstall intel-grafana
kubectl delete -f persistent.yaml

```
### Pre - Re-create persistent storage if set persistence.enabled=true in next step 
```
kubectl apply -f persistent.yaml
```

### Standard deployment
```
helm install \
-f /data/otel/helm/grafana/values.yaml \
--set adminPassword="admin" \
--set persistence.enabled=true \
--set persistence.storageClassName="manual" \
intel-grafana grafana/grafana
```
### Import dashboard during deployment
```
helm install \
-f /data/otel/helm/grafana/values.yaml \
--set adminPassword="admin" \
--set persistence.enabled=true \
--set persistence.storageClassName="manual" \
--set-file dashboards.default.power-insight-01.json=/data/otel/helm/grafana/dashboards/power-insight.json \
intel-grafana grafana/grafana
```
### Pass in datasource configuration during deployment (error, WIP)
```
helm install \
-f /data/otel/helm/grafana/values.yaml \
--set adminPassword="admin" \
--set persistence.enabled=true \
--set persistence.storageClassName="manual" \
--set-file 'datasources.datasources\.yaml.yaml'=/data/otel/helm/grafana/config/config.yaml \
--set-file dashboards.default.power-insight-01.json=/data/otel/helm/grafana/dashboards/power-insight.json \
intel-grafana grafana/grafana
```
