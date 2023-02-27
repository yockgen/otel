```
helm install \
-f /data/otel/helm/otelcol/values.yaml \
--set-file=otelconfig=/data/otel/helm/otelcol/config/config-backend-gateway-01.yaml \
otelgateway /data/otel/helm/otelcol
```

```
helm install \
-f /data/otel/helm/otelcol/values-agent.yaml \
--set-file=otelconfig=/data/otel/helm/otelcol/config/config-edge-agent.yaml \
otelcolagent /data/otel/helm/otelcol
```
