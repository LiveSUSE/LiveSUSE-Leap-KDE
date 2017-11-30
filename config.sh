#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$name]..."

#======================================
# SuSEconfig
#--------------------------------------
echo "** Running suseConfig..."
suseConfig

echo "** Running ldconfig..."
/sbin/ldconfig

#======================================
# Setup default runlevel
#--------------------------------------
baseSetRunlevel 5

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey


#======================================
# Firewall Configuration
#--------------------------------------
echo '** Configuring firewall...'
systemctl enable SuSEfirewall2

sed --in-place -e 's/# solver.onlyRequires.*/solver.onlyRequires = true/' /etc/zypp/zypp.conf

#======================================
# Sysconfig Update
#--------------------------------------
echo '** Update sysconfig entries...'
baseUpdateSysConfig /etc/sysconfig/keyboard KEYTABLE us.map.gz
baseUpdateSysConfig /etc/sysconfig/network/config FIREWALL yes
systemctl disable wicked
systemctl enable NetworkManager
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT lat9w-16.psfu
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER sddm
baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM plasma5


#======================================
# Setting up overlay files 
#--------------------------------------
echo '** Setting up overlay files...'
chown root:root /license.tar.gz
chmod 644 /license.tar.gz
chown root:root /usr/share/applications/live-installer.desktop
chmod 644 /usr/share/applications/live-installer.desktop
chown root:root /usr/bin/start-install.sh
chmod 755 /usr/bin/start-install.sh

#======================================
# /etc/sudoers hack to fix #297695
# (Installation Live DVD: no need to ask for password of root)
# https://bugzilla.novell.com/show_bug.cgi?id=297695
#--------------------------------------
sed -i -e "s/ALL ALL=(ALL) ALL/ALL ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
chmod 0440 /etc/sudoers

# Create LiveDVD user linux
/usr/sbin/useradd -m -u 999 linux -c "LiveDVD User" -p ""

# delete passwords
passwd -d root
passwd -d linux
# empty password is ok
pam-config -a --nullok

# bug 544314, we only want to disable the bit in common-auth-pc
# https://bugzilla.novell.com/show_bug.cgi?id=544314
sed -i -e 's,^\(.*pam_gnome_keyring.so.*\),#\1,'  /etc/pam.d/common-auth-pc

# Automatically log in user linux
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER_AUTOLOGIN linux

# Official repositories
# (as found in http://download.opensuse.org/distribution/leap/42.3/repo/oss/control.xml)

#rm /etc/zypp/repos.d/*.repo
zypper addrepo -f -K -n "openSUSE-Leap-42.3-Update" http://download.opensuse.org/update/leap/42.3/oss/ repo-update
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Update-Non-Oss" http://download.opensuse.org/update/leap/42.3/non-oss/ repo-update-non-oss
zypper addrepo -f -K -n "openSUSE-Leap-42.3-Oss" http://download.opensuse.org/distribution/leap/42.3/repo/oss/ repo-oss
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Non-Oss" http://download.opensuse.org/distribution/leap/42.3/repo/non-oss/ repo-non-oss
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Debug" http://download.opensuse.org/debug/distribution/leap/42.3/repo/oss/ repo-debug
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Debug-Non-Oss" http://download.opensuse.org/debug/distribution/leap/42.3/repo/non-oss/ repo-debug-non-oss
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Update-Debug" http://download.opensuse.org/debug/update/leap/42.3/oss repo-debug-update
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Update-Debug-Non-Oss" http://download.opensuse.org/debug/update/leap/42.3/non-oss/ repo-debug-update-non-oss
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Source" http://download.opensuse.org/source/distribution/leap/42.3/repo/oss/ repo-source
zypper addrepo -d -K -n "openSUSE-Leap-42.3-Source-Non-Oss" http://download.opensuse.org/source/distribution/leap/42.3/repo/non-oss/ repo-source-non-oss

# bug 989897, avoid creating desktop directory on KDE so that the default items are added on first login
cp /usr/share/applications/live-installer.desktop /usr/share/kio_desktop/DesktopLinks/
# Set the application as being "trusted"
chmod a+x /usr/share/kio_desktop/DesktopLinks/live-installer.desktop

# openSUSE Bug 984330 overlayfs requires AppArmor attach_disconnected flag
# https://bugzilla.opensuse.org/show_bug.cgi?id=984330

# Linux Kamarada issue #1 unable to ping
# https://github.com/kamarada/kiwi-config-Kamarada/issues/1
sed -i -e 's/\/{usr\/,}bin\/ping {/\/{usr\/,}bin\/ping (attach_disconnected) {/g' /etc/apparmor.d/bin.ping

#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
c_rehash

