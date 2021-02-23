# packer-M1-parallels-fedora33
Packer script to build vagrant Fedora33 VM box using Parallels provider to run on Mac M1 ARM.

## Dependencies
* Parallels beta for Mac M1 ARM https://www.parallels.com/directdownload/pdbeta
* Fedora 33 desktop for ARM architecture https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Workstation/aarch64/iso/Fedora-Workstation-Live-aarch64-33-1.2.iso or pick another from https://arm.fedoraproject.org.
* homebrew https://brew.sh/
* git installed using homebrew https://formulae.brew.sh/formula/git#default 
* packer installed using homebrew https://formulae.brew.sh/formula/packer#default
* vagrant installed using homebrew https://formulae.brew.sh/cask/vagrant#default

## Packer script based on git@github.com:boxcutter/fedora
The normal packer will fail in Parallels when prlctl thinks the .ISO is for x86_64 rather than ARM architecture.
See https://forum.parallels.com/threads/arm64-iso-and-vhdx-images.351847/
"The images are indeed currently misdetected as x86. Therefore, manual installation is required." 

So instead I made a Parallels PVM with the yum upgrade done, parallels tools installed and the initial steps from their packer scripts done manually. The packer build can then be done from the PVM instead 
https://www.packer.io/docs/builders/parallels/pvm

## Manual steps
From Mac
* Install homebrew ````$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
* Install git ````$ brew install git
* Install packer ````$ brew install packer
* Install vagrant ````$ brew install vagrant
* Install Parallels beta for Mac M1 (download link above)
* Create a VM manually from ISO Fedora-Workstation-Live-aarch64-33-1.2.iso to create /Users/peter/dev/box-parallels-pvm/Fedora Linux Base.pvm (download link for ISO above).
* I followed the first steps in the boxcutter/fedora scripts manually - see below details. It's also problematic getting the parallels tools installed using the packer script, so I mounted them from the UI and installed from shell manually.
* I hit an issue in Fedora 33 not allowing ssh-rsa public keys which stopped the vagrant insecure key working https://forums.centos.org/viewtopic.php?t=74233 and to fix this added a line to custom-script.sh to append ,ssh-rsa to the PubkeyAcceptedKeyTypes line in /etc/crypto-policies/back-ends/opensshserver.config inside the Fedora VM.

## Details

### Create Parallels PVM
    Download ISO to ~/Downloads
    Run Parallels beta
    Create VM named "Fedora Linux Base"
    Pick the Fedora ISO
    Do installation
    In initial setup create user vagrant password vagrant  
    login as vagrant
    $ sudo bash
    # echo "UseDNS no" >> /etc/ssh/sshd_config
    # echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
    # dnf -y upgrade
    # reboot
    wait then login again as vagrant and become root
    $ sudo bash
    # yum install kernel-devel kernel-headers gcc make perl dkms selinux-policy-devel
    # eject
    in Parallels for the VM Devices go to CD-ROM and unmount Fedora ISO
    # reboot  
    In Parallels do the Mount Install Parallels Tools or under Devices/CD select its ISO, then from shell as root
    # mount /dev/cdrom /mnt
    # cd /mnt
    # ./install
    press TAB and RETURN etc. until installed then reboot
    shutdown the VM
    In Parallels Control Panel right click "Remove Fedora Linux Base" but keep the files.

### Move PVM
From Mac move the Parallel VM directory - not sure this step was necessary. I did this to avoid collision with Parallels saying the vagrant VM is a duplicate.
    $ mkdir -p ~/dev/box-parallels-pvm
    $ mv ~/Parallels/Fedora\ Linux\ Base.pvm ~/dev/box-parallels-pvm/

### Check out packer script and build vagrant box
From Mac
    $ cd ~/dev
    $ git clone git@github.com:peterdragon/packer-M1-parallels-fedora33.git
    $ cd packer-M1-parallels-fedora33
    $ packer build vagrant.json
    ...
    ==> Builds finished. The artifacts of successful builds are:
    --> parallels-pvm: 'parallels' provider box: box/parallels/fedora33-ws-0.1.0.box  
    created ~/dev/box-parallels-pvm/box/parallels/fedora33-ws-0.1.0.box

### Install vagrant, add Parallels as a provider and add the fedora box
From Mac
    $ brew install vagrant
    $ vagrant plugin install vagrant-parallels
    $ vagrant box add ~/dev/box-parallels-pvm/box/parallels/fedora33-ws-0.1.0.box --name 'fedora33-ws'

### To make a VM from the fedora box
From Mac
    $ mkdir ~/dev/box-fedora33-ws
    $ cd ~/dev/box-fedora33-ws
    $ vagrant init
    edit the Vagrantfile and add provider section
      config.vm.provider "parallels" do |prl|
        prl.name = "fedora"
        prl.check_guest_tools = false
      end
    $ vagrant up  
  
The virtual machine boots and vagrant sets a new ssh key the first time.
    to log into the box
    $ vagrant ssh 
    to shutdown the box
    $ vagrant halt 
