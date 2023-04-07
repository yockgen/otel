### Crontab Job
@reboot /home/yockgen/jetson-inference/data/monitor.sh
@reboot /data/temp/telegraf-1.26.1/usr/bin/telegraf --config /data/otel/telegraf/tapo/tapo.conf

