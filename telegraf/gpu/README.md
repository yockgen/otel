## Telegraf for Intel i915 GPU metries

1. Install intel-gpu-top utilities

```
apt-get update 
apt-get install intel-gpu-tools
```

2. Added following config input into Telegraf config file:

```
...
[[inputs.exec]]
  commands = ["/data/otel/telegraf/gpu/gpu-usage.sh"]
  name_override = "gpu_busyness_3d_percentage_01"
  timeout = "10s"
  data_format = "value"
  data_type = "float"
  interval = "20s"
 ... 
```

3. Running Telegraf with above step config file, for example:

```
telegraf --config /data/otel/telegraf/demo.conf
```
