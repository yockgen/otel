### Run Docker Compose with customized config file, for example:
 
 1. To Run Edge OtelCol Agent with default config 
 ```
 CONFIG=./config-edge-agent.yaml docker-compose up
```

2. To Run Bakcned OtelCol Gateway with default config 
 ```
 CONFIG=./config-backend-gateway-01.yaml docker-compose up
```

Please refer to example config files provided in this repo for reference.

### Setup Nginx Load Balancer 
For multiple OTELCOL gateways/agents setup on the cluster for better performance, NGINX load balancer could be use:

1. Install Nginx
```
apt-get purge nginx nginx-common nginx-full
apt-get install nginx -y
```

2. Create load balancing configuration file 
```
nano /etc/nginx/conf.d/loadbalancer.conf
```

content looks like following:
```
upstream backend {        
        keepalive 16; 
        server 192.168.1.107:52199; #<-- add in your otelcol instance 0 
        server 192.168.1.111:52199; #<-- add in your otelcol instance N    

    }

    server {
        listen 52123 http2;
        location / {	       
        	 grpc_pass grpc://backend;                                 
	}
 
}
```

3. Restart NGINX
```
systemctl restart nginx
systemctl status nginx.service
```

4. Configure Telegraf config file access to OtelCol cluster via Load Balancer, for example:

```
[[outputs.opentelemetry]]
  service_address  = "192.168.1.110:52123"
```


