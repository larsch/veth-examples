#!/bin/sh
ip netns delete ns3 2>/dev/null
ip netns delete ns2 2>/dev/null
ip netns delete ns1 2>/dev/null
ip link delete dev1 2>/dev/null
ip link delete dev2 2>/dev/null
ip link delete alpha1 2>/dev/null
ip link delete alpha2 2>/dev/null
ip link delete beta1 2>/dev/null
ip link delete beta2 2>/dev/null
exit 0
