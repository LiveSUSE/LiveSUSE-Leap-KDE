#!/bin/bash

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Mount system filesystems
#--------------------------------------
baseMount

#======================================
# Call configuration code/functions
#--------------------------------------

# Setup baseproduct link
suseSetupProduct

# Add missing gpg keys to rpm
suseImportBuildKey

# Activate services
suseInsertService sshd

# Setup default target, multi-user
baseSetRunlevel 3

# Remove package docs
rm -rf /usr/share/doc/packages/*
rm -rf /usr/share/doc/manual/*
rm -rf /opt/kde*

# only basic version of vim is
# installed; no syntax highlighting
sed -i -e's/^syntax on/" syntax on/' /etc/vimrc

# SuSEconfig
suseConfig

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

#======================================
# Exit safely
#--------------------------------------
exit 0
