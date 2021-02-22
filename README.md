# packer-M1-parallels-fedora33
Packer script to build vagrant Fedora33 VM box using Parallels provider to run on Mac M1 ARM.

Dependencies:
https://www.parallels.com/directdownload/pdbeta
https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Workstation/aarch64/iso/Fedora-Workstation-Live-aarch64-33-1.2.iso

Based on git@github.com:boxcutter/fedora
but using a Parallels PVM with the upgrade and parallels tools already installed and initial steps from their packer scripts done manually.
https://www.packer.io/docs/builders/parallels/pvm

The normal packer will fail when prlctl thinks the .ISO is for x86_64 rather than ARM architecture.
See https://forum.parallels.com/threads/arm64-iso-and-vhdx-images.351847/
"The images are indeed currently misdetected as x86. Therefore, manual installation is required." 

Install Parallels beta for Mac M1.
Create a VM manually from ISO Fedora-Workstation-Live-aarch64-33-1.2.iso to create /Users/peter/dev/box-parallels-pvm/Fedora Linux Base.pvm.
I follow the steps in the boxcutter/fedora scripts manually. It's also problematic getting the parallels tools installed using the packer script, so I also did them from the UI and shell manually.

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
  wait then login again as vagrant
  $ sudo bash
  # yum install kernel-devel kernel-headers gcc make perl dkms selinux-policy-devel
  # eject
  in Parallels for the VM Devices go to CD-ROM and unmount ISO
  # reboot  
  In Parallels do the Mount Install Parallels Tools, then from shell
  # mount /dev/cdrom /mnt
  # cd /mnt
  # ./install
  press TAB and RETURN etc. until installed then reboot
  shutdown the VM
  In Parallels Control Panel right click "Remove Fedora Linux Base". Keep the files.

  From Mac
  $ mkdir -p ~/dev/box-parallels-pvm
  $ mv ~/Parallels/Fedora\ Linux\ Base.pvm ~/dev/box-parallels-pvm/
  $ cd ~/dev
  $ git clone git@github.com:peterdragon/packer-M1-parallels-fedora33.git
  $ cd packer-M1-parallels-fedora33
  $ packer build vagrant.json
  ...
  ==> Builds finished. The artifacts of successful builds are:
  --> parallels-pvm: 'parallels' provider box: box/parallels/fedora33-ws-0.1.0.box  
  created ~/dev/box-parallels-pvm/box/parallels/fedora33-ws-0.1.0.box

 You can now 'vagrant add' this .box file, create a Vagrantfile that references it and do 'vagrant up' to get a running Fedora VM under Mac M1.

