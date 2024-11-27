# Cloudflare Beacon

Cloudflare [Warp Zero Trust](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/ "Warp Zero Trust") 
(ZT) provides a form of VPN to Cloudflare's secure network.
The Zero Trust client establishes an encrypted tunnel uplink. It routes traffic from
the user's computer through the tunnel so that it is encapsulated and encrypted when
it moves onto the local, potentially malicious or insecure network.

## Playbook and Role

The cloudflare beacon is deployed by the
[cloudflare-beacon-pb.yaml](./cloudflare-beacon-pb.yaml) playbook file:

    ansible-playbook [--check] ./cloudflare-beacon-pb.yaml
	
The hosts are defined in `inventory.yaml` in the *cloudflare_beacons* group.

## Managed Networks

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

## CoreOS - A Container Optimized OS

[Fedora CoreOS](https://fedoraproject.org/coreos/ "Fedora CoreOS") is a linux distribution 
designed to run software containers. It is based on Fedora, but using *rpm-ostree* to create
an immutable OS.  Rather than installing user software into the OS using traditional packages,
application software and services are run in software containers using *podman*.

The immutable OS and container instances means that the OS and the
applications it hosts are almost entirely decoupled and can safely be updated entirely
independently. CoreOS updates on the stable stream are released every two weeks. The service
container images can be checked and updated as new images are released.

## Nginx in a Container Instance

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

## Systemd and Quadlets

Recently a suite of projects converged to make it possible to run
containers as systemd services. The working interface for this purpose
is Podman [quadlets](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html
"Podman Quadlets"). Systemd manages retrieving and updating the container
images and running and controlling the container instances. 

The beacon web server is deployed as an Nginx web server in a
container managed as a systemd service. The deployment process is to
place the needed configuration files, placing the container service
spec and notifying systemd to enable and run it.

## X509 Certificates and Fingerprint

The last part of the beacon configuration is the x509 certificate with
CN and Alt DNS fields defined. Cloudflare requires that the beacon
answer queries for HTTPS and that the certificate fingerprint match
the value configured on the known network. For this Nginx server the
x509 certificate and the RSA private key used to create it are
combined into a single file with the two ASCII armored blocks.

If this file exists when the playbook begins, it is copied to the
target host and deployment proceeds. If the file does not yet exist,
the role will generate the key and x509 certificate, combine them into
the single file in place and then pull back that file and store it
locally for future use.

This file is the critical sensitive value for identifying the Known
Network. It should not be saved in a public repository without
additional file-level encryption.

The fingerprint used by Cloudflare is an sha256 hash of the
certificate. The fingerprint can be generated from the file like this:

    # Write and extract the fingerprint in a form suitable for
    # Cloudflare Known Network specification
    cat <cert file> | \
	  openssl x509 -fingerprint -sha256 | \
	  grep Fingerprint | \
	  cut -d= -f2 | \
	  tr -d : | \
	  tr '[:upper:]' '[:lower:]'

This command writes the cert contents including the fingerprint, then
isolates the fingerprint string, removes colons (:) and converts the
string to lowercase.

The fingerprint, along with the IP address and TCP port for the web
server are provided to define the Known Network. Then the
administrator can define a profile that is applied when Warp detects
this network.
