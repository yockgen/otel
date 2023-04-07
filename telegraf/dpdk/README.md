### Installing DPDK on the node
Installing pre-requisties tools
```
sudo apt-get install -y meson python3-pyelftools python-pyelftools
```
Get any DPDK release that suited from [here](http://core.dpdk.org/download/)
```
wget http://fast.dpdk.org/rel/dpdk-22.11.1.tar.xz
tar xf dpdk-22.11.1.tar.xz
```
Compiling DPDK from source
```
cd ./dpdk-22.11.1
meson build 
cd build
ninja 
sudo ninja install
```
### Bootup - each time device booted or restarted
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
### Run any DPDK application,for example:
- Running TESTPMD DPDK app
```
/data/dpdk/dpdk-stable-22.11.1/build/app/dpdk-testpmd --telemetry -- -i
```
- Try to send some packets out from interface
```
testpmd> set fwd txonly
testpmd> show port info 0
testpmd> set eth-peer  0 54:b2:03:9f:23:f2
testpmd> start
testpmd> stop
```
- Observing if DPDK telemetry metrices been captured in target Dashboard


