# The Case for CoreOS

[Fedora CoreOS](https://fedoraproject.org/coreos) is a distribution
variant of Fedora Linux. It is used as the upstream of [Red Hat
Enterprise Linux CoreOS](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/architecture/architecture-rhcos)
(RHCOS). RHCOS is only supported as an infrastructure component of and
OpenShift deployment, but Fedora CoreOS has utility broadly in
traditional network infrastructure.

CoreOS is an immutable operating system designed to run containerized
workloads. This has two major effects on the operational use:

* Atomic Update and Rollback
* Automatic OS Updates
* Application Decoupling

There are also side-effects of this design decision that provide both
benefit and constraints.

The characteristics of CoreOS make it a good candidate for hosting
local network infrastructure services in small and and medium sized
organizations. It does pose a siginificant difference in philosophy
and practice of risk management, update management and security. It
won't be for everyone in every environment, but it offers a low cost,
low maintenance alternative to conventional OS deployments for
infrastructure services.

## Atomic Update and Rollback

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

## Infrastructure Server Lifecycle - Zincati

The other element that will raise eyebrows is the delivery mechanism
for updates. New CoreOS images are provided in three `streams` labeled *stable*,
*testing*, and *next*. The stable stream consists of updates that have
been tested through the two more volitile streams. A new image is
posted to the stable stream approximately every two weeks. CoreOS runs
a system service called [zincati](https://coreos.github.io/zincati/)
that polls periodically for image updates.  When it finds one,
downloads it, commits it to the OStree 

Conventional distributions publish frequent updates to a
package repository and then periodic major releases. This method
allows the sysadmins to pull updates as they desire. It puts the
responsibility on the consumer to pick and implement an update
schedule. 

## Application Decoupling

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

