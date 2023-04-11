Steps to run whole structure with self signed certificate

- Create certificate with openssl

1. cd /data/otel/tls/selfsign/ssl
2. ./ssl.sh 192.168.1.22   <---- change the IP address to your IP

- Launch infrastructure

deploy influxdb
//get token

deploy otel gateway

deploy nginxloadbalancer

deploy otel agent
 
deploy grafana

- Test

deploy telegraf

open grafana in web

check datasource

check data from telegraf
