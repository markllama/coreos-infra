# Ansible, CoreOS ad Containers

Once the CoreOS system is installed, the system services and configuration are
installed using Ansible. CoreOS is tuned to run containers. The playbooks and roles
defined here install and configure infrastructure services to run a lab
or small network.


# Name Service - CoreDNS 

    sudo podman run --detach --restart=always \
	  --name coredns \
	  --publish 53:53/udp \
	  --volume=/opt/coredns/:/root/ \
	  --workdir=/root \
	  coredns/coredns -conf /root/Corefile

# Time Service - Chrony - TBD

Time service is the one network service that is installed natively on CoreOS.
It needs to be configured to sync from appropriate upstream servers and to offer
time service on the local network. 

# Network Address Assignment - DHCPD - TBD

When new devices connect to the network they need to request and recieve an IP
address assignment. 

# Secure Networking - Cloudflare Warp

## `cloudflared` tunnel

## Known Network Beacon

