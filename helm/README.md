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

1. Mod to correct node port of "backend" /data/otel/helm/otelcol/config/config-edge-agent.yaml
```
exporters:
  otlp:    
    endpoint: http://192.168.1.107:31172
```
```
root@node1:/data/otel# kubectl get svc
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
kubernetes                 ClusterIP   10.233.0.1      <none>        443/TCP           2d3h
otelcol-gateway            ClusterIP   10.233.44.138   <none>        54199/TCP         6h23m
otelcol-gateway-nodeport   NodePort    10.233.55.209   <none>        54200:31172/TCP   6h23m
```

2. Mod telegraf config to correct node port of "agent"  
```
[[outputs.opentelemetry]]
  service_address  = "192.168.1.161:30695"
```
```
root@kbl01:/data/otel# kubectl get svc
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
kubernetes               ClusterIP   10.43.0.1      <none>        443/TCP           13m
otelcol-agent-nodeport   NodePort    10.43.201.64   <none>        55200:30695/TCP   28s
otelcol-agent            ClusterIP   10.43.183.42   <none>        55199/TCP         28s
```
