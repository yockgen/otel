### filelog configuration

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



