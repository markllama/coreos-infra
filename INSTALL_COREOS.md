<!DOCTYPE html>
<html>
<head>
  <meta name="generator" content=
  "HTML Tidy for HTML5 for Linux version 5.8.0">
  <title></title>
</head>
<body>
  <div style="text-align: left;">
    <span style="font-size: medium;">In <a href=
    "https://electron-swamp.blogspot.com/2025/01/the-case-for-coreos-network.html"
    target="_blank">the first post</a>&nbsp;in this series I laid
    out a set of arguments to support the use of <a href=
    "https://fedoraproject.org/coreos" target="_blank">Fedora
    CoreOS</a>&nbsp;to host network services for small and medium
    local networks. That was the "why". In this one I mean to show
    the first step of the "how".</span>
  </div>
  <h2 style="text-align: left;"><span style="font-size: medium;">OS
  Installation</span></h2>
  <div style="text-align: left;">
    <span style="font-size: medium;">OS installation is, at it's
    most basic, writing data to a storage unit for first boot. The
    storage can be a spinning disk, or an SSD of one form or
    another (I'm going to use 'disk' from here on in for any
    bootable storage media). Most distributions provide a bootable
    image with an interactive installer program on it, and in many
    cases a GUI interface. These guide a normal user through a
    one-time process and the result is a complete running desktop
    for the user.&nbsp; Server distributions often provide a way
    (for instance, Red Hat Kickstart) to define and apply all the
    changes an admin would want for system initialization. These
    include complex disk and network configurations, package
    selection, user definitions.</span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;"><br></span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;">The other extreme is an OS
    that is provided as a binary image and is merely copied to the
    destination. This is the most common method for distributions
    made for small ARM machines like Raspberry Pi. To customize one
    of these you have to write to the media and then mount the
    image on a running machine (like my laptop) and make the needed
    changes before the first boot. I often do this to enable the
    UART for a serial console and to place an SSH private key for
    the default user.</span>
  </div>
  <h1 style="text-align: left;"><span style=
  "font-size: medium;">The CoreOS Installer</span></h1>
  <div style="text-align: left;">
    <span style="font-family: inherit;"><span style=
    "font-size: medium;">CoreOS falls somewhere in the middle. A
    new CoreOS instance is written to the disk</span><span style=
    "font-family: inherit; font-size: medium;">&nbsp;</span></span><span><span style="font-family: inherit; font-size: medium;">using
    a single CLI command:</span></span> <span style=
    "font-family: courier;"><a href=
    "https://github.com/coreos/coreos-installer" target=
    "_blank">coreos-installer</a></span><span style=
    "font-family: inherit;">.</span><span style=
    "font-family: inherit; font-size: large;">&nbsp;</span><span style="font-family: inherit; font-size: medium;">The
    installer can be run from a bootable live-image of CoreOS or it
    can run on a separate machine with the storage temporarily
    attached.&nbsp;</span><span style=
    "font-family: inherit; font-size: medium;"><span>The installer
    is available on Fedora Linux in the RPM of the same
    name.</span><span>&nbsp;</span></span>
  </div>
  <div style="text-align: left;">
    <span style=
    "font-family: inherit; font-size: large;"><br></span>
  </div>
  <div style="text-align: left;">
    <span style="font-family: inherit;"><span style=
    "font-size: medium;">In it's simplest form the installer takes
    only a single argument: the location to write the image
    data.</span></span>
  </div>
  <div style="text-align: left;">
    <span style=
    "font-family: inherit; font-size: large;"><br></span>
  </div>
  <blockquote style=
  "border: none; margin: 0px 0px 0px 40px; padding: 0px;">
    <div style="text-align: left;">
      <span style=
      "background-color: #274e13; color: #d9ead3; font-family: courier;">
      sudo coreos-installer install /dev/sdb</span>
    </div>
  </blockquote>
  <div style="text-align: left;">
    &nbsp;
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;">This command will pull the
    default stream (stable) from the default location (the Fedora
    CoreOS download repository) and write it onto the indicated
    block device. In this example it is an SD card that was
    previously inserted into a USB port. The installer does not
    make any customisations to the image.&nbsp;</span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;"><br></span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;"><b>NOTE:</b> <i>Be sure to
    unmount any auto-mounted existing filesystems from the device
    before overwriting.</i></span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;"><br></span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;"><b>WARNING</b>: <i>Be sure
    you're writing to the correct device. Overwriting your OS is
    easy and painful.</i></span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;"><i><br></i></span>
  </div>
  <div style="text-align: left;">
    <span style="font-size: medium;">The</span> <span style=
    "font-family: courier;">install</span><span style=
    "font-family: inherit; font-size: medium;">&nbsp;command can
    take a number of arguments to select the image stream, the
    image source and to control the target platform and
    architecture. We'll use these only as needed to vary from the
    defaults. We will use two arguments that indicate where to find
    a configuration file that will be laid into the image and used
    on first boot to complete the customization.&nbsp; We'll use
    slightly different arguments for the two sample targets based
    on the installation method and the characteristics of the
    target devices. Before we can run the installer we need to
    define the customisations and generate the configuration files
    for the target systems.</span>
  </div>
  <h1 style="text-align: left;"><span style=
  "font-family: inherit; font-size: medium;">&nbsp;Something about
  Fire Metaphors</span></h1>
  <div>
    <span style="font-family: inherit; font-size: medium;">The
    minimalist nature of CoreOS means there aren't a lot of knobs
    that need setting to get a basic running system. The CLI
    arguments for</span> <span style=
    "font-family: courier;">coreos-installer</span><span style=
    "font-family: inherit; font-size: medium;">&nbsp;define what
    image gets placed and where, but they don't make any changes to
    the image itself. To customize the installed system we need to
    define the elements we want configured and what values we want
    them to have.</span>
  </div>
  <div>
    <br>
  </div>
  <div>
    <span style="font-size: medium;">CoreOS actually uses two
    semantically identical configuration specifications. Users
    provide their configuration using the <a href=
    "https://coreos.github.io/butane/" target="_blank">butane</a>
    spec and then transform it into&nbsp;<a href=
    "https://coreos.github.io/ignition/">ignition</a>&nbsp;format
    to submit to the installer for first boot.&nbsp;</span>
  </div>
  <div>
    <span style="font-size: medium;"><br></span>
  </div>
  <div>
    <span style="font-size: medium;">Ignition is a JSON structured
    data format that was defined for the original CoreOS. At some
    point, someone decided that JSON was too difficult for
    sysadmins to manage, so Butane was defined using YAML for
    structured data instead. I'm not sure why no one just included
    a YAML parser on the CoreOS image, but for now the workflow for
    creating configurations is to write the configuration in Butane
    (YAML) and then transform it into Ignition (JSON) and then to
    submit that to the installer.&nbsp;</span>
  </div>
  <div>
    <span style="font-size: medium;"><br></span>
  </div>
  <div>
    <span style="font-size: medium;">While annoying, this process
    does have one significant benefit. The</span> <span style=
    "font-family: courier;">butane</span><span style=
    "font-family: inherit; font-size: medium;">&nbsp;command runs
    validation on the configuration file during the transformation
    and reports any schema violations so that they can be corrected
    before installation. This doesn't do anything to make sure that
    the configuration values are correct, but at least it insures
    that there are no errors in the white-space delimited YAML
    form.</span>
  </div>
  <h1 style="text-align: left;"><span style=
  "font-family: inherit; font-size: medium;">Make It Your
  Own</span></h1>
  <div>
    <span style="font-size: medium;">The Butane specification only
    has two required fields to start the YAML file:</span>
  </div>
  <div>
    <span style="font-size: medium;"><br></span>
  </div><span style="font-family: courier;">variant:
  fcos<br></span><span style="font-family: courier;">version:
  1.6.0</span>
  <div>
    <span style="font-family: courier;"><br></span>
  </div>
  <div>
    <span style="font-family: inherit; font-size: medium;">This
    indicates that the target system is Fedora CoreOS and that the
    Butane schema version is 1.6.0. The following fields must all
    conform to that schema, but all of the fields are
    optional.</span>
    <div>
      <h2 style="text-align: left;"><span style=
      "font-family: inherit; font-size: medium;">Who Are You? Who
      Who? Who Who?</span></h2>
      <div>
        <span style="font-family: inherit; font-size: medium;">A
        bare CoreOS image will boot and initialize any NICs it
        detects. Without any configuration provided each NIC that
        detects link will broadcast a DHCP request. The system will
        configure the NICs according to the DHCP response that they
        receive. If the NIC's MAC address has a lease reservation
        defined, the DHCP server will provide a stable known IP
        address in the DHCP response. Finally the system will start
        an SSH daemon attached to the active interfaces and begin
        accepting inbound connection requests.</span>
      </div>
      <div>
        <span style=
        "font-family: inherit; font-size: medium;"><br></span>
      </div>
      <div>
        <span style="font-family: inherit; font-size: medium;">The
        basic image only has two users defined:</span> <span style=
        "font-family: courier;">root</span> <span style=
        "font-family: inherit; font-size: medium;">and</span>
        <span style="font-family: courier;">core</span><span style=
        "font-family: inherit; font-size: medium;">. Neither user
        has a password defined or a public key set to allow a user
        to log in. By convention the</span> <span style=
        "font-family: courier;">root</span> <span style=
        "font-family: inherit; font-size: medium;">user never does.
        The</span> <span style="font-family: courier;">core</span>
        <span style="font-family: inherit; font-size: medium;">user
        is a member of the</span> <span style=
        "font-family: courier;">sudoers</span> <span style=
        "font-family: inherit; font-size: medium;">group and so can
        escalate privileges as needed... once the user is logged
        in.</span>
      </div>
      <div>
        <span style=
        "font-family: inherit; font-size: medium;"><br></span>
      </div>
      <div>
        <span style="font-family: inherit; font-size: medium;">The
        Butane spec includes a section for defining new users
        including providing an SSH public key. It is possible also
        to provide a password, but that places sensitive
        information (the password hash) into the butane file and so
        is discouraged. New users, and user customisations are
        defined in the</span> <span style=
        "font-family: courier;">passwords</span> <span style=
        "font-family: inherit; font-size: medium;">section.</span>
      </div>
      <div>
        <span style=
        "font-family: inherit; font-size: medium;"><br></span>
      </div>
      <div>
        <span style="font-family: courier;">passwords:</span>
      </div>
      <div>
        <span style="font-family: courier;">&nbsp; users:<br>
        &nbsp; &nbsp; - core:<br>
        &nbsp; &nbsp; &nbsp; ssh_authorized_keys: |<br>
        &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;ssh-ed25519
        AAAAC3NzaC1lZDI1NTE5AAAAIGl7GOHs9enyGZ7tTSh8E8G5mE+B9gyVVnz41hRyxbbN
        Infrastructure Ansible Key</span>
      </div>
      <div>
        <span style=
        "font-family: inherit; font-size: medium;"><br></span>
      </div>
      <div>
        <span style="font-size: medium;">The</span> <span style=
        "font-family: courier;">core</span> <span style=
        "font-size: medium;">user already exists so the user will
        be created as default.&nbsp; This section just tells the
        Ignition system to add this public key to the</span>
        <span style="font-family: courier;">core</span>
        <span style="font-size: medium;">user's authorized_keys
        file. After first boot, a user holding the private key will
        be able to log into the new system as the</span>
        <span style="font-family: courier;">core</span>
        <span style="font-size: medium;">user.</span>
      </div>
      <h2 style="text-align: left;"><span style=
      "font-size: medium;">Where Am I?</span></h2>
      <div>
        <span style="font-size: medium;">The only other
        configuration I like to make is to tell the system it's own
        name. The system name is defined in /etc/hostname so I'll
        add a section to create this file and insert the text
        needed.</span>
      </div>
      <div>
        <span style="font-size: medium;"><br></span>
      </div>
      <div>
        <span style="font-size: medium;"><br></span>
      </div>
      <h1 style="text-align: left;"><span style=
      "font-size: medium;">Installer Controls</span></h1>
      <div>
        <span style="font-size: medium;">There are a number of CLI
        arguments for the installer that are used to affect the
        image results. These are used to select custom image stream
        or locations. In this demonstration we're only going to use
        two, both related to&nbsp;</span>
      </div>
      <div style="text-align: left;">
        <span style="font-size: medium;"><br></span>
      </div>
    </div>
  </div>
</body>
</html>
