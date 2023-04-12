## Telemetry Docker With Selfsign TLS certificate

### Create certificate with openssl
```
cd /data/otel/tls/selfsign/ssl
./ssl.sh <node IP> #<--- insert your Node IP
```
### Launch influxdb Docker
```
cd /data/otel/tls/selfsign/influxdb
docker-compose up
```
### Launch otel gateway
```
cd /data/otel/tls/selfsign/otel
nano +22 config-backend-gateway-01.yaml
```
Edit this part
```
   influxdb:
    endpoint: https://<Influxdb IP>:58100 #<--- insert your Influxdb IP
```
launch container
```
CONFIG=./config-backend-gateway-01.yaml docker-compose -f docker-compose-dual.yml up
```
### Launch nginxloadbalancer
install nginx
```
apt-get purge nginx nginx-common nginx-full
apt-get install nginx -y
```
edit configuration
```
cd /data/otel/tls/selfsign/nginxlb
nano loadbalancer.conf
```
edit the following
```
upstream backend {        
        keepalive 16;

        server <otel gateway 1 IP>:52197; #<--- insert otel gateway IP
        server <otel gateway 2 IP>:52198; #<--- insert another otel gateway IP
    }

    server {
        
        listen 52123 ssl http2;
        
        ssl_certificate         /data/otel/tls/selfsign/ssl/self-signed.crt; #<--- path to ssl cert
        ssl_certificate_key     /data/otel/tls/selfsign/ssl/self-signed.key; #<--- path to ssl key
        
        location / {	                      
                grpc_pass grpcs://backend; #<--- make sure using grpcs protocol
	}
}
```
copy config file to system folder
```
cp loadbalancer.conf /etc/nginx/conf.d/
```
restart nginx
```
systemctl restart nginx
systemctl status nginx.service
```
### Launch otel agent
```
cd /data/otel/tls/selfsign/otel
nano +15 config-edge-agent.yaml
```
edit this part
```
  otlp:
    endpoint: https://<nginx loadbalancer IP>:52123 #<--- insert nginx loadbalancer IP
```
```
CONFIG=./config-edge-agent.yaml docker-compose up
```
### Launch grafana
```
cd /data/otel/tls/selfsign/grafana
docker-compose up
```

### Launch telegraf
```
cd /data/otel/tls/selfsign/telegraf
telegraf --config=telegraf.conf
```
