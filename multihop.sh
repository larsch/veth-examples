#!/bin/sh -exu
./cleanup.sh

# Create network namespace 'ns1'
ip netns add ns1
ip -n ns1 link set lo up

# Create network namespace 'ns2'
ip netns add ns2
ip -n ns2 link set lo up

# Create network namespace 'ns3'
ip netns add ns3
ip -n ns3 link set lo up

# Create network device veth pair 'alpha1' and 'alpha2'
ip link add alpha1 type veth peer name alpha2

# Move 'alpha1' into 'ns1' and configure
ip link set alpha1 netns ns1
ip -n ns1 link set alpha1 up
ip -n ns1 addr add 10.0.0.1/24 dev alpha1

# Move 'alpha2' into 'ns2' and configure
ip link set alpha2 netns ns2
ip -n ns2 link set alpha2 up
ip -n ns2 addr add 10.0.0.2/24 dev alpha2

# Create network device veth pair 'beta2' and 'beta3'
ip link add beta2 type veth peer name beta3

# Move 'beta2' into 'ns2' and configure
ip link set beta2 netns ns2
ip -n ns2 link set beta2 up
ip -n ns2 addr add 192.168.177.1/24 dev beta2

# Move 'beta3' into 'ns2' and configure
ip link set beta3 netns ns3
ip -n ns3 link set beta3 up
ip -n ns3 addr add 192.168.177.2/24 dev beta3

# Configure routing
ip -n ns1 route add 192.168.177.0/24 via 10.0.0.2
ip -n ns3 route add 10.0.0.0/24 via 192.168.177.1
ip netns exec ns2 sysctl -w net.ipv4.ip_forward=1
ip netns exec ns2 cat /proc/sys/net/ipv4/ip_forward

# Ping self and remote
ip netns exec ns1 ping -c 1 10.0.0.1
ip netns exec ns1 ping -c 1 10.0.0.2
ip netns exec ns1 ping -c 1 192.168.177.1
ip netns exec ns1 ping -c 1 192.168.177.2
ip netns exec ns2 ping -c 1 10.0.0.1
ip netns exec ns2 ping -c 1 10.0.0.2
ip netns exec ns2 ping -c 1 192.168.177.1
ip netns exec ns2 ping -c 1 192.168.177.2
ip netns exec ns3 ping -c 1 10.0.0.1
ip netns exec ns3 ping -c 1 10.0.0.2
ip netns exec ns3 ping -c 1 192.168.177.1
ip netns exec ns3 ping -c 1 192.168.177.2

ip netns exec ns1 traceroute 192.168.177.2
ip netns exec ns3 traceroute 10.0.0.1
