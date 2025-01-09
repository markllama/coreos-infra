# coreos-infra

One of the most challenging issues with network infrastructure
services in a corporate environment is the management of updates and
security. CoreOS provides a new way to manage the operation and
updates for critical infrastructure while providing both security and
robustness for both the hosts and the services they run.

## CoreOS

[Fedora CoreOS](https://fedoraproject.org/coreos) is a distribution
variant of Fedora Linux. It is used as the upstream of [Red Hat
Enterprise Linux CoreOS](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/architecture/architecture-rhcos)
(RHCOS). RHCOS is only supported as an infrastructure component of and
OpenShift deployment, but Fedora CoreOS has utility broadly in
traditional network infrastructure.

CoreOS is an immutable operating system designed to run containerized
workloads. This has two major effects on the operational use:

* Atomic Update and Rollback
* Application Decoupling

There are also side-effects of this design decision that provide both
benefit and constraints.

### Atomic Update and Rollback

All operating system distributions start as a filesystem that
contains the kernel and the rest of the support files that make up the
OS. In most distributions, this is mounted read/write. Write access to
the filesystem is controlled by user access controls, but the files
are inherently able to be updated and overwritten. The operating
system files are controlled by a package manager but this is an
unenforced convention. Updates are performed by package updates, that
overlay the currently running files, replacing them with new
ones. Once a file has been changed, the old version is lost and cannot
easily be restored without retrieving and executing backups and even
then the restoration of a previous state can't be guarenteed. If a user can
escalate their permissions to admin or root level, then the user can
make changes to the running OS. Whole toolsets exist just to ensure
the integrity of the OS over time.

CoreOS uses a filesystem (or meta-filesystem?) called
[rpm-ostree](https://coreos.github.io/rpm-ostree/). Rpm-ostree is a
variant of [ostree](https://ostreedev.github.io/ostree/)that combines
the (RPM)[rpm.org] package management system with a transactional
filesystem. The result is an operating system that both prevents
ad-hoc (or malicious) updates and provides atomic roll-back in the
event that an update introduces a problem. When an update is applied,
rpm-ostree produces a new commit in the filesystem, but the changed
files are invisible to the currently running OS. The system must be
rebooted using the new commit to run the updated system. If the new OS
fails to boot or introduces problems it is possible to rollback and
reboot with a single command.

That last point will raise the eyebrows of people for whom uptime is
the ultimate metric of stability but modern application architectures
distribute services across multiple machines.  This means that the reboot of
a single host should not affect the operation of the service as a
whole. Basic infrastructure services are all designed with redunancy,
making a service reboot a frequent but invisible event for
users. Today, if a host presents a single point of failure for a
service that really indicates a flaw in the implementation of the
service.

### Application Decoupling

The other feature of `rpm-ostree` that appears at first as a problem
is that **you can't install software**. That's not strictly true. There
are mechanisms to *layer* packages into the immutable image, but
that's actively discouraged as a standard way of running applications.

CoreOS is designed to run software as containerized
applications. Other than the minimal required software to boot and
manage the OS, the only other major service installed by default is
[podman](https://podman.io). Podman is the Red Hat alternative user
interface to Docker. Podman runs the same
[OCI](https://opencontainers.org) containers as Docker, but it
integrates more closely with the OS, eliminating the need for a
separate container management service. In 2022 systemd merged a feature
called [quadlets](https://github.com/containers/quadlet). Quadlets
allow systemd to manage containers as system services, eliminating the
need to install the service software directly into the OS file tree.

So, CoreOS can run not only user applications but system services as
containers. Containerized software decouples application software and
versioning from the operating system, meaning that the OS and the
application can be updated independently. There is no longer any risk of
introducing incompatibilities between the OS and an application or
between applications running on the same host.

## Deploying CoreOS

CoreOS is installed by laying the initial image onto the local storage
device and then rebooting. On some systems this is done by booting an
installer image first. In others the installer runs on a second host
and installs onto an SD Card or other media.

### OS Config 

CoreOS is by design a minimalist OS distribution. There are very few
initial configuration options. The OS is configured using a single
configuration file and an installer binary that places the image onto
disk and sets the configuration file to be applied on first boot.

The initial system only has a single non-root user, named `core`. The
root user has no password set and no SSH key by default so there is no
direct root access either on the console or network. The only
configuration that is properly required is to set an SSH public key on
the `core` user so that, after the first boot, you can access the
system over a network.

Notably, the Butane spec does not include network settings. CoreOS
uses [NetworkManager](https://networkmanager.dev/). The simplest way
to configure the network is with DHCP, applying a lease reservation
for the MAC address of the primary NIC of the system.

#### Butane

CoreOS is meant to be installed mechanically. That is, it doesn't
provide an interactive installer like most linux distributions. A
CoreOS installation is much simpler than most distributions because
CoreOS only has one purpose: running containers. The recommended
configuration format is called
[butane](https://coreos.github.io/butane/). 

The butane spec defines a YAML schema to place the image on storage,
define initial users, add files or services, and tune kernel boot
parameters.

Butane can be installed as a package on many systems but it is
generally easier to run it as a container.

#### Ignition

For some obscure reasons I can't fathom, the original,
semanticly identical JSON spec called
[ignition](https://coreos.github.io/ignition/) created by the CoreOS
company before it was purchased and replaced by Red Hat's [Project
Atomic](https://projectatomic.io/) is still the actual format used
during installation. Butane files are transformed to Ignition before
installation begins. That's all the `butane` binary does. It validates
the input format and converts it to Ignition. Sometimes it doesn't pay
to ask questions.

### Boot/Install

#### PC - x86_64 - USB

#### Raspberry Pi 4 - aarch64 - SDCard

#### PC - x86_64 - Netboot

## Service Installation

* DNS - CoreDNS
* NTP - Chrony
* DHCP - TBD
* Monitoring - TBD

* User Management - FreeIPA?
