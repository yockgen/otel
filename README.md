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

5. Configure the Telegraf config to correct OTELCOL hosted machine IP address and keep the port number as 4317, snippet as below 
```
...
[[outputs.opentelemetry]]
  service_address  = "192.168.1.107:4317"
```
