#!/usr/bin/env bash

set -eux

# Sample custom configuration script - add your own commands here
# to add some additional commands for your environment
#
# For example:
# dnf install -y curl wget git tmux firefox xvfb

dnf install -y curl wget git nano vim man unzip lynx mutt perl-App-cpanminus perl-local-lib ntp ntpdate glibc ansible
