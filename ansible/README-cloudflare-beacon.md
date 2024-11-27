# Cloudflare Beacon

Cloudflare [Warp Zero Trust](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/ "Warp Zero Trust") 
(ZT) provides a form of VPN to Cloudflare's secure network.
The Zero Trust client establishes an encrypted tunnel uplink. It routes traffic from
the user's computer through the tunnel so that it is encapsulated and encrypted when
it moves onto the local, potentially malicious or insecure network.

# Managed Networks

When the ZT client connects to the Cloudflare mesh, it checks if it is on one of a list of 
[Managed Networks](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/managed-networks/ "Managed Networks"). 
If it detects a known network the client can tune the list of
networks that will be tunneled. It can exclude specific networks (the local network in
a secure company office) so that they are allowed to connect directly. Or on a 
properly secure network it can include only those private destinations that are
only accessible through a tunnel.

The ZT client determines it's location in the network by probing for one of a defined
set of *beacons*.  A beacon is a web server at a well known IP address that is not
accessible except on the managed network.  The web server answers HTTPS queries and
encrypts the traffic with a server key that uniquely identifies this network.

# CoreOS - A Container Optimized OS

[Fedora CoreOS](https://fedoraproject.org/coreos/ "Fedora CoreOS") is a linux distribution 
designed to run software containers. It is based on Fedora, but using *rpm-ostree* to create
an immutable OS.  Rather than installing user software into the OS using traditional packages,
application software and services are run in software containers using *podman*.

The immutable OS and container instances means that the OS and the
applications it hosts are almost entirely decoupled and can safely be updated entirely
independently. CoreOS updates on the stable stream are released every two weeks. The service
container images can be checked and updated as new images are released.

# Nginx in a Container Instance

The beacon can be implemented with any web server that can respond with SSL. There are
a number of sources for Apache containers, but the simplest image that is actively maintained
is [Nginx](https://nginx.org "Nginx Official web site") from [Dockerhub](https://hub.docker.com/_/nginx "Nginx Container Image on Dockerhub"). Simply running this image will create a web
server on port 80. It only takes two files mounted into they container to create an SSL
server.

The first file is a simple configuration file:

    server {
    listen       443 ssl;
    server_name  {{ ansible_fqdn }} ;
    ssl_certificate     beacon.crt;
    ssl_certificate_key beacon.crt;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    
    }

The `{{ ansible_fqdn }}` is a variable defined when the configuration is deployed. 
This configuration sets a listener on port 443 with SSL. The certificate and key are in
a single file named `beacon.crt` that is mounted into the same directory as the config
file.

The second file contains an RSA private key and and X509 self-signed certificate, both
ASCII armored. This file is created the first time the ansible role is deployed and/or
provided as a pre-created file. The key and cert are sensitive files and so should
not be stored in Github without being encrypted or protected.

These files are placed on the host in `/etc/cloudflare-beacon` and are mounted into
the container on startup using *volume* statements during the container invocation.

# Systemd and Quadlets

Recently `systemd` was extended to include [quadlets](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html "Podman Quadlets").
These are systems services that run as
software containers. Systemd manages retrieving and updating the container images
and running and controlling the container instances.

