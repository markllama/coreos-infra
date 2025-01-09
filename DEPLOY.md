# Deploying CoreOS

CoreOS is installed by laying the initial image onto the local storage
device and then rebooting. On some systems this is done by booting an
installer image first. In others the installer runs on a second host
and installs onto an SD Card or other media.

## OS Config 

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

### Butane

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

### Ignition

For some obscure reasons I can't fathom, the original,
semanticly identical JSON spec called
[ignition](https://coreos.github.io/ignition/) created by the CoreOS
company before it was purchased and replaced by Red Hat's [Project
Atomic](https://projectatomic.io/) is still the actual format used
during installation. Butane files are transformed to Ignition before
installation begins. That's all the `butane` binary does. It validates
the input format and converts it to Ignition. Sometimes it doesn't pay
to ask questions.

## Boot/Install

### PC - x86_64 - USB

### Raspberry Pi 4 - aarch64 - SDCard

### PC - x86_64 - Netboot
