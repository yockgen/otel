# Telemetry infrastructure configuration
Telegraf->OpenTelemetry Collector (OTELCOL)

## Prerequisites

1. Install Opentelemetry Collector
```
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.70.0/otelcol-contrib_0.70.0_linux_amd64.deb

sudo dpkg -i otelcol-contrib_0.70.0_linux_amd64.deb
```

2. Install Telegraf
```
cat <<EOF | sudo tee /etc/apt/sources.list.d/influxdata.list
deb https://repos.influxdata.com/ubuntu $(lsb_release -cs) stable
EOF

sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -

sudo apt update
sudo apt install telegraf

sudo systemctl start telegraf && sudo systemctl enable telegraf
```

## Configuration
1. Backup /etc/otelcol/config.yaml

2. Replace the OTEL config file with simplified version from the repo
```
  cp /{repo}/config/otelcol/config.yaml /etc/otelcol/config.yaml
```

3. Backup /etc/telegraf/telegraf.conf

4. Replace the Telegraf config file with simplified version from the repo
```
cp /{repo}/otel/config/telegraf/telegraf.conf /etc/telegraf/telegraf.conf
```

5. Modify Telegraf config to correct OTELCOL hosted machine IP address and keep the port number as 4317, snippet as below 

```
...
[[outputs.opentelemetry]]
  service_address  = "192.168.1.107:4317"
```

## Run
1. Create output folder
```
mkdir /data
mkdir /data/temp
```

2. Open first SSH terminal to run OTELCOL (Opentelemetry Collector):

```
cd /{repo}/config/otelcol/
chmod +x run.sh
./run.sh
```

expected output
```
root@node1:/data/otel/config/otelcol# ./run.sh
2023-02-10T14:58:54.202+0800    info    service/telemetry.go:90 Setting up own telemetry...
2023-02-10T14:58:54.202+0800    info    service/telemetry.go:116        Serving Prometheus metrics      {"address": ":8888", "level": "Basic"}
2023-02-10T14:58:54.204+0800    info    service/service.go:128  Starting otelcol-contrib...     {"Version": "0.70.0", "NumCPU": 8}
.....
2023-02-10T14:58:54.205+0800    info    service/service.go:145  Everything is ready. Begin running and processing data.
```

3. Open second SSH terminal to run Telegraf to emit telemetric data to OTELCOL:

```
cd /{repo}/config/telegraf/
chmod +x run.sh
./run.sh
```
expected output
```
root@node1:/data/otel/config/telegraf# ./run.sh
2023-02-10T07:07:47Z I! Starting Telegraf 1.21.4+ds1-0ubuntu2
2023-02-10T07:07:47Z I! Using config file: /etc/telegraf/telegraf.conf
2023-02-10T07:07:47Z W! DeprecationWarning: Plugin "inputs.io" deprecated since version 0.10.0 and will be removed in 2.0.0: use 'inputs.diskio' instead
2023-02-10T07:07:47Z I! Loaded inputs: cpu disk diskio kernel mem net netstat processes swap system
2023-02-10T07:07:47Z I! Loaded aggregators:
2023-02-10T07:07:47Z I! Loaded processors:
2023-02-10T07:07:47Z I! Loaded outputs: file opentelemetry
2023-02-10T07:07:47Z I! Tags enabled: host=192.168.1.107
2023-02-10T07:07:47Z W! Deprecated inputs: 1 and 0 options
2023-02-10T07:07:47Z I! [agent] Config: Interval:10s, Quiet:false, Hostname:"192.168.1.107", Flush Interval:10s
2023-02-10T07:07:47Z D! [agent] Initializing plugins
2023-02-10T07:07:47Z D! [agent] Connecting outputs
2023-02-10T07:07:47Z D! [agent] Attempting connection to [outputs.file]
2023-02-10T07:07:47Z D! [agent] Successfully connected to outputs.file
2023-02-10T07:07:47Z D! [agent] Attempting connection to [outputs.opentelemetry]
2023-02-10T07:07:47Z D! [agent] Successfully connected to outputs.opentelemetry
....
2023-02-10T07:09:09Z D! [outputs.opentelemetry] Buffer fullness: 0 / 10000 metrics
2023-02-10T07:09:09Z D! [outputs.file] Buffer fullness: 0 / 10000 metrics
```
