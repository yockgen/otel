### Pre-requisties
```
pip install PyP100
```
### Crontab Job
```
@reboot /data/temp/telegraf-1.26.1/usr/bin/telegraf --config /data/otel/telegraf/tapo/tapo.conf
```
