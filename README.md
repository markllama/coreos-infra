# coreos-infra

One of the most challenging issues with network infrastructure
services in a corporate environment is the management of updates and
security. CoreOS provides a new way to manage the operation and
updates for critical infrastructure while providing both security and
robustness for both the hosts and the services they run.

## CoreOS for Infrastructure

CoreOS is... a lot of buzzwords. To a first approximation it's a
distribution variant of Fedora Linux. It can run any software that you
could run on Fedora. It can run software containers or virtual
machines.

Then the buzzwords come in: *minimal*, *immutable*, *checkpointed*, or
tuned for *containerized workloads*. CoreOS was originally designed to
run software containers and to decouple the OS functions from the
applications and services. To learn more check out [The Case for
CoreOS](./COREOS.md).

Here I'm going to treat the utility of CoreOS for infrastructure as a
given and focus on the practice of deploying, configuring and
maintaining common network infrastructure services on CoreOS.

## CoreOS Deployment

CoreOS does not have an interactive installer, and it does not use Kickstart, the standard automated Fedora/Red Hat installer. Instead, CoreOS is installed onto the system storage using the `coreos-installer` program and a simplified system configuration schema known as `butane`. You can find details for deploying CoreOS in [Deploying CoreOS](./DEPLOY.md).

## Service Installation

* DNS - CoreDNS
* NTP - Chrony
* DHCP - TBD
* Monitoring - TBD

* User Management - FreeIPA?
