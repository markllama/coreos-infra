#

# CoreDNS 

    sudo podman run --detach --restart=always \
	  --name coredns \
	  --publish 53:53/udp \
	  --volume=/opt/coredns/:/root/ \
	  --workdir=/root \
	  coredns/coredns -conf /root/Corefile
