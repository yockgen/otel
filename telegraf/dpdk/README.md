
### Node bootup
1. Setup DPDK Huge Page
```
mkdir -p /dev/hugepages
mountpoint -q /dev/hugepages || mount -t hugetlbfs nodev /dev/hugepages
echo 2048 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
```

2. Check Available NIC for DPDK 
```
python3 /data/dpdk/dpdk-stable-22.11.1/usertools/dpdk-devbind.py --status
```

3. Bind targetted NIC to DPDK, for example:
```
ifconfig enp88s0 down 
python3 /data/dpdk/dpdk-stable-22.11.1/usertools/dpdk-devbind.py -b vfio-pci 0000:58:00.0
```

### Run Telegraf with DPDK telemetry enable, for example
```
telegraf --config /data/otel/telegraf/dpdk/demo-dpdk.conf
```
### Run any DPDK application,for example
```
/data/dpdk/dpdk-stable-22.11.1/build/app/dpdk-testpmd --telemetry -- -i
```
