### Open Telemetry Filelog configuration

1. docker-compose
```
version: "3.9"
services:
  opentelemetry-collector-contrib:
    image: "otel/opentelemetry-collector-contrib:0.71.0"
    command: ["--config=/etc/otel-collector-config.yml"]
    volumes:
      - ${CONFIG}:/etc/otel-collector-config.yml
      - /data/temp/logs.log:/etc/logs.log
      - /data/temp/yockgen.log:/etc/yockgen.log
    ports:
      - "52199:4317"
      - "52198:4318"

```

2. otel config file

```
receivers:
  otlp/1:
    protocols:
      grpc:
        #endpoint: 0.0.0.0:4317
      http:

  #otlp/2:
   # protocols:
    #  http:
     #   endpoint: 0.0.0.0:4318

  filelog:
    include: [/etc/yockgen.log]
    start_at: beginning
    operators:
      - type: regex_parser
        regex: '^(?P<time>\d{4}-\d{2}-\d{2}) (?P<sev>[A-Z]*) (?P<msg>.*)$'
        timestamp:
          parse_from: attributes.time
          layout: '%Y-%m-%d'
        severity:
          parse_from: attributes.sev

processors:
  batch:

exporters:
  otlp:
    endpoint: http://10.165.242.40:52123
    tls:
      insecure: true

  logging:
    verbosity: detailed
    sampling_initial: 5
    sampling_thereafter: 20

  file/test01:
    path: /etc/logs.log

  influxdb:
    endpoint: http://10.165.242.40:58100
    timeout: 500ms
    sending_queue:
      enabled: true
      num_consumers: 3
      queue_size: 10
    retry_on_failure:
      enabled: true
      initial_interval: 1s
      max_interval: 3s
      max_elapsed_time: 10s
    org: intel
    bucket: intel
    token: lqcZg_m-upX-mDGS_UQrrhSVr4LqxSYMq_h1ZL-ygulvCPdWM9A6t4T7Y5dniPm93Ami43l85k9ht5Bcv_Kiew==
    metrics_schema: telegraf-prometheus-v1

service:
  pipelines:
    logs:
      receivers: [filelog]
      processors: [batch]
      exporters: [logging]
    metrics:
      receivers: [otlp/1]
      processors: [batch]
      exporters: [otlp]
```

3. Run Otel

```
root@inteladmin-NUC7i5DNHE:/data/otel/docker/otel# CONFIG=./config-edge-agent.yaml docker-compose up
```

4. Open another terminal, append line on /data/temp/yockgen.log
```
root@inteladmin-NUC7i5DNHE:/data# cat /data/temp/yockgen.log
2023-05-16 INFO Something routine
2023-05-16 ERROR Something bad happened!
2023-05-16 DEBUG Some details...
2023-05-16 DEBUG Some details...yockgen now!!!
2023-05-16 DEBUG Some details...yockgen now 02!!!
2023-05-16 DEBUG Some details...yockgen now 03!!!
2023-05-16 DEBUG Some details...yockgen now 04!!!
2023-05-16 DEBUG Some details...yockgen now 04!!!
2023-05-16 DEBUG Some details...yockgen now 07!!!
2023-05-16 DEBUG Some details...yockgen now 08!!!
2023-05-16 DEBUG Some details...yockgen now 09!!!
```

5. Observing yockgen.log detail is stdout on Otel terminal
```
opentelemetry-collector-contrib_1  | 2023-05-16T03:07:24.906Z   info    LogsExporter    {"kind": "exporter", "data_type": "logs", "name": "logging", "#logs": 1}
opentelemetry-collector-contrib_1  | 2023-05-16T03:07:24.906Z   info    ResourceLog #0
opentelemetry-collector-contrib_1  | Resource SchemaURL:
opentelemetry-collector-contrib_1  | ScopeLogs #0
opentelemetry-collector-contrib_1  | ScopeLogs SchemaURL:
opentelemetry-collector-contrib_1  | InstrumentationScope
opentelemetry-collector-contrib_1  | LogRecord #0
opentelemetry-collector-contrib_1  | ObservedTimestamp: 2023-05-16 03:07:24.636953138 +0000 UTC
opentelemetry-collector-contrib_1  | Timestamp: 2023-05-16 00:00:00 +0000 UTC
opentelemetry-collector-contrib_1  | SeverityText: DEBUG
opentelemetry-collector-contrib_1  | SeverityNumber: Debug(5)
opentelemetry-collector-contrib_1  | Body: Str(2023-05-16 DEBUG Some details...yockgen now 09!!!)
opentelemetry-collector-contrib_1  | Attributes:
opentelemetry-collector-contrib_1  |      -> log.file.name: Str(yockgen.log)
opentelemetry-collector-contrib_1  |      -> time: Str(2023-05-16)
opentelemetry-collector-contrib_1  |      -> sev: Str(DEBUG)
opentelemetry-collector-contrib_1  |      -> msg: Str(Some details...yockgen now 09!!!)
opentelemetry-collector-contrib_1  | Trace ID:
opentelemetry-collector-contrib_1  | Span ID:
opentelemetry-collector-contrib_1  | Flags: 0
opentelemetry-collector-contrib_1  |    {"kind": "exporter", "data_type": "logs", "name": "logging"}
```

## Fluent-bit configuration
1. Run Opentelemetry Collector with below config:
```
receivers:  
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
processors:
  batch:
exporters:

  logging:
    logLevel: debug
    verbosity: detailed
    sampling_initial: 5
    sampling_thereafter: 200

  influxdb:
    endpoint: http://192.168.1.107:32701
    timeout: 5000ms
    org: intel
    bucket: intel
    token: X6zYQsXQdkC4K-WE7Uza_Z7yYWkENe3PAbNPIjryr4_KECA75QoLqALgsX9XQjWMFhdhZFz1TiLjxYUiM7B1zw==
    metrics_schema: telegraf-prometheus-v1

    sending_queue:
      enabled: true
      num_consumers: 3
      queue_size: 10

    retry_on_failure:
      enabled: true
      initial_interval: 1s
      max_interval: 3s
      max_elapsed_time: 10s

service:
  pipelines:
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [influxdb,logging]

```
2. Fluent-bit config:
```
[SERVICE]
    flush        1
    daemon       Off
    log_level    info   
    

[INPUT]
    name kmsg
    Tag kernel

[OUTPUT]
    name opentelemetry
    match *
    host 192.168.1.161
    port 8087
    tls Off
    tls.verify Off
    Metrics_uri /v1/metrics
    Logs_uri /v1/logs
    Traces_uri /v1/traces
    Log_response_payload True
    add_label app fluent-bit-yockgen
    add_label hostname yockgen-test

```

3. Run Fluent-Bit
```
 /opt/fluent-bit/bin/fluent-bit -c fluent-bit.conf
```

4. Sending some customized message to kernel log since above steps is monitoring kernel log:
```
echo 'yockgen: testing kernel message' > /dev/kmsg
```

5. Observing output in Otel:
```
2023-05-16T14:08:19.902+0800    info    service/telemetry.go:90 Setting up own telemetry...
2023-05-16T14:08:19.903+0800    info    service/telemetry.go:116        Serving Prometheus metrics      {"address": ":8888", "level": "Basic"}
2023-05-16T14:08:19.903+0800    info    exporter/exporter.go:290        Development component. May change in the future.        {"kind": "exporter", "data_type": "logs", "name": "logging"}
2023-05-16T14:08:19.904+0800    info    service/service.go:128  Starting otelcol-contrib...     {"Version": "0.70.0", "NumCPU": 4}
2023-05-16T14:08:19.904+0800    info    extensions/extensions.go:41     Starting extensions...
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:86 Starting exporters...
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:90 Exporter is starting... {"kind": "exporter", "data_type": "logs", "name": "influxdb"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:94 Exporter started.       {"kind": "exporter", "data_type": "logs", "name": "influxdb"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:90 Exporter is starting... {"kind": "exporter", "data_type": "logs", "name": "logging"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:94 Exporter started.       {"kind": "exporter", "data_type": "logs", "name": "logging"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:98 Starting processors...
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:102        Processor is starting...        {"kind": "processor", "name": "batch", "pipeline": "logs"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:106        Processor started.      {"kind": "processor", "name": "batch", "pipeline": "logs"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:110        Starting receivers...
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:114        Receiver is starting... {"kind": "receiver", "name": "otlp", "pipeline": "logs"}
2023-05-16T14:08:19.904+0800    warn    internal/warning.go:51  Using the 0.0.0.0 address exposes this server to every network interface, which may facilitate Denial of Service attacks    {"kind": "receiver", "name": "otlp", "pipeline": "logs", "documentation": "https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/security-best-practices.md#safeguards-against-denial-of-service-attacks"}
2023-05-16T14:08:19.904+0800    info    otlpreceiver@v0.70.0/otlp.go:94 Starting GRPC server    {"kind": "receiver", "name": "otlp", "pipeline": "logs", "endpoint": "0.0.0.0:4317"}
2023-05-16T14:08:19.904+0800    warn    internal/warning.go:51  Using the 0.0.0.0 address exposes this server to every network interface, which may facilitate Denial of Service attacks    {"kind": "receiver", "name": "otlp", "pipeline": "logs", "documentation": "https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/security-best-practices.md#safeguards-against-denial-of-service-attacks"}
2023-05-16T14:08:19.904+0800    info    otlpreceiver@v0.70.0/otlp.go:112        Starting HTTP server    {"kind": "receiver", "name": "otlp", "pipeline": "logs", "endpoint": "0.0.0.0:8087"}
2023-05-16T14:08:19.904+0800    info    service/pipelines.go:118        Receiver started.       {"kind": "receiver", "name": "otlp", "pipeline": "logs"}
2023-05-16T14:08:19.904+0800    info    service/service.go:145  Everything is ready. Begin running and processing data.
2023-05-16T14:13:09.821+0800    info    LogsExporter    {"kind": "exporter", "data_type": "logs", "name": "logging", "#logs": 14}
2023-05-16T14:13:09.821+0800    info    ResourceLog #0
Resource SchemaURL:
ScopeLogs #0
ScopeLogs SchemaURL:
InstrumentationScope
LogRecord #0
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2023-05-16 06:13:09.240773717 +0000 UTC
SeverityText:
SeverityNumber: Unspecified(0)
Body: Map({"log":"May 16 13:47:15 KBL02 kubelet[24095]: I0516 13:47:15.916178   24095 flags.go:64] FLAG-YOCKGEN003: --v=\"2\""})
Trace ID:
Span ID:
Flags: 0
LogRecord #1
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2023-05-16 06:13:09.240783203 +0000 UTC
SeverityText:
SeverityNumber: Unspecified(0)
Body: Map({"log":"May 16 13:47:15 KBL02 kubelet[24095]: I0516 13:47:15.916178   24095 flags.go:64] FLAG-YOCKGEN001: --v=\"2\""})
Trace ID:
Span ID:
Flags: 0
LogRecord #2
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2023-05-16 06:13:09.240784662 +0000 UTC
SeverityText:
SeverityNumber: Unspecified(0)
Body: Map({"log":"May 16 13:47:15 KBL02 kubelet[24095]: I0516 13:47:15.916165   24095 flags.go:64] FLAG: --tls-min-version=\"\""})
Trace ID:
Span ID:
Flags: 0
LogRecord #3
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2023-05-16 06:13:09.240785865 +0000 UTC
SeverityText:
SeverityNumber: Unspecified(0)
Body: Map({"log":"May 16 13:47:15 KBL02 kubelet[24095]: I0516 13:47:15.916169   24095 flags.go:64] FLAG: --tls-private-key-file=\"\""})
Trace ID:
Span ID:
Flags: 0
LogRecord #4
ObservedTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2023-05-16 06:13:09.240787136 +0000 UTC
SeverityText:
SeverityNumber: Unspecified(0)
Body: Map({"log":"May 16 13:47:15 KBL02 kubelet[24095]: I0516 13:47:15.916172   24095 flags.go:64] FLAG: --topology-manager-policy=\"none\""})

```

6. Retrive log in Grafana, it stored as "logs" in measurement list, example query as below:
```
from(bucket: "intel")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "logs"
  )
```

