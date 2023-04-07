### Crontab Job
Ensure grant execute permission to "monitor.sh"
```
@reboot /data/temp/telegraf-1.26.1/usr/bin/telegraf --config /data/otel/telegraf/tapo/tapo.conf
```
