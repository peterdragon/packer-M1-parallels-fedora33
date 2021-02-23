#!/usr/bin/env bash

set -eux

# Sample custom configuration script - add your own commands here
# to add some additional commands for your environment
#
# For example:
# dnf install -y curl wget git tmux firefox xvfb

# https://forums.centos.org/viewtopic.php?t=74233
# Fedora 33 missing ssh-rsa required for vagrant insecure key
perl -i.orig -pe 's/^(PubkeyAcceptedKeyTypes .*)$/$1,ssh-rsa/' /etc/crypto-policies/back-ends/opensshserver.config

dnf install -y curl wget git nano vim man unzip lynx mutt perl-App-cpanminus perl-local-lib ntp ntpdate glibc ansible
