#! /bin/bash
printf "\n   ____ _                 _      _                    "
printf "\n  / ___| | ___  _   _  __| |    / \   _ __  _ __  ___ "
printf "\n | |   | |/ _ \| | | |/ _\` |   / _ \ | '_ \| '_ \/ __|"
printf "\n | |___| | (_) | |_| | (_| |  / ___ \| |_) | |_) \__ \\"
printf "\n  \____|_|\___/ \__,_|\__,_| /_/   \_\ .__/| .__/|___/"
printf "\n                                     |_|   |_|        "
printf "\n\n Copyright 2017 | CloudCone LLC | All Rights Reserved "
printf "\n ---------------------------------------------------- "
printf "\n\n          CENTOS 7 - BBR INSTALLATION SCRIPT          "
printf "\n\n   \033[0;31mWARNING: \033[0m TO BE INSTALLED ON A FRESH SYSTEM ONLY"
printf "\n\n ------------- \033[0;32mConfiguring Cloud Mirror\033[0m ------------- \n"
wget -q http://mirror.cloudcone.net/centos/7/apps/install-cc-mirror.sh
source ./install-cc-mirror.sh &>> ~/cloud-apps.log
installMirror
printf "\n [--] Updating sources"
yum clean all &>> ~/cloud-apps.log
yum repolist &>> ~/cloud-apps.log
printf "\n [ok] Cloud Mirror installation complete"
printf "\n\n ---------------- \033[0;32mInstalling Packages\033[0m --------------- \n"
printf "\n [--] Updating CentOS Base and Packages \033[0;32m(go grab a coffee, this might take a long time...)\033[0m"
yum update -y -q &>> ~/cloud-apps.log
printf "\n [--] Importing ELRepo"
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org &>> ~/cloud-apps.log
printf "\n [--] Installing ELRepo"
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm &>> ~/cloud-apps.log
printf "\n [ok] Package installation complete"
printf "\n\n ------------- \033[0;32mInstalling Latest Kernel\033[0m ------------- \n"
printf "\n [--] Getting latest version from server"
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available &>> ~/cloud-apps.log
printf "\n [--] Installing latest stable mainline kernel"
yum --enablerepo=elrepo-kernel install kernel-ml -y &>> ~/cloud-apps.log
printf "\n [--] Reconfiguring GRUB for latest kernel"
sed -i 's,GRUB_DEFAULT=saved,GRUB_DEFAULT=0,g' /etc/default/grub &>> ~/cloud-apps.log
printf "\n [--] Recreating kernel configuration"
grub2-mkconfig -o /boot/grub2/grub.cfg &>> ~/cloud-apps.log
printf "\n [ok] Kernel upgrade complete"
printf "\n\n -------- \033[0;32mEnabling TCP BBR Congestion Control\033[0m ------- \n"
printf "\n [--] Modifying system defaults"
printf 'net.core.default_qdisc=fq\n net.ipv4.tcp_congestion_control=bbr' > /etc/sysctl.d/latest-kernel-bbr.conf
printf "\n [ok] Google BBR configuration complete"
printf "\n\n ----------------------------------------------------\n\n"
echo " After reboot run the following commands to ensure BBR was installed successfully:"
echo "  # sysctl net.core.default_qdisc"
echo "  # sysctl net.ipv4.tcp_congestion_control"
echo ""
echo " Thank you for using Cloud Apps! For bug reports or"
echo " recommendations send an email to damian@cloudcone.com"
echo ""
echo " ----------------------------------------------------"
echo ""
read -r -p " A reboot is required to complete the installation. Reboot now? [Y,n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    printf " System is going into reboot\n\n"
    cd && rm -rf ~/cloudapps &>> ~/cloud-apps.log && shutdown -r now
else
    printf " \033[0;32mExiting Cloud Apps without rebooting - make sure to reboot later\033[0m\n\n"
fi
