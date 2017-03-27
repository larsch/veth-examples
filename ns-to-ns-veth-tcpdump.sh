#!/bin/sh -exu
./cleanup.sh

# Create network namespace 'ns1'
ip netns add ns1
ip -n ns1 link set lo up

# Create network namespace 'ns2'
ip netns add ns2
ip -n ns2 link set lo up

# Create network device veth pair 'dev1' and 'dev2'
ip link add dev1 type veth peer name dev2

# Move 'dev1' into 'ns1' and configure
ip link set dev1 netns ns1
ip -n ns1 link set dev1 addrgenmode none
ip -n ns1 link set dev1 up
ip -n ns1 addr add 10.0.0.1/24 dev dev1

# Move 'dev2' into 'ns2' and configure
ip link set dev2 netns ns2
ip -n ns2 link set dev2 addrgenmode none
ip -n ns2 link set dev2 up
ip -n ns2 addr add 10.0.0.2/24 dev dev2

ip netns exec ns1 tcpdump -i dev1 -w log1 &
tcpdump1=$!

ip netns exec ns2 tcpdump -i dev2 -w log2 &
tcpdump2=$!

sleep 1.0

ip netns exec ns1 ping -c 1 10.0.0.1
ip netns exec ns1 ping -c 1 10.0.0.2
ip netns exec ns2 ping -c 1 10.0.0.2
ip netns exec ns2 ping -c 1 10.0.0.1

sleep 1.0

kill $tcpdump1
kill $tcpdump2

wait $tcpdump1
wait $tcpdump2

tcpdump -r log1
tcpdump -r log2
