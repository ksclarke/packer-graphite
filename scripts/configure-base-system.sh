#! /bin/bash

#
# We can configure the system to do automated package upgrades for security issues or to just send an email when
# the system needs to be updated.  We use 'unattended-upgrade' for the first cast and 'apticron' for the second.
#

# We want to get notified of pending security updates regardless of whether we're going to auto-update
sudo debconf-set-selections <<< "postfix postfix/mailname string $SERVER_HOST_NAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y bsd-mailx

# Check whether to continue with automatic OS security updates; if we don't, let's still notify via email
if [ "$AUTOMATIC_OS_SECURITY_UPDATES" = false ]; then
  sudo apt-get install -y apticron
  sudo sed -i "s/^EMAIL\=\"root\"/EMAIL=\"$SERVER_ADMIN_EMAIL\"/g" /etc/apticron/apticron.conf

  # Update our sources.list file so that it only includes security updates
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.original
  sudo grep "-security" /etc/apt/sources.list | grep -v "#" > /tmp/security.sources.list
  sudo mv /tmp/security.sources.list /etc/apt/sources.list

  # We don't continue if we're not going to perform automated security updates
  exit 0
fi

# Install common files necessary for automated reboots or for email notification of a needed reboot
sudo apt-get install -y update-notifier-common

# Begin configuring automated updates
printf "APT::Periodic::Update-Package-Lists \"1\";" | sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
printf "\nAPT::Periodic::Unattended-Upgrade \"1\";" | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
printf "\nAPT::Periodic::Verbose \"2\";" | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades >/dev/null

# Use heredoc to create the unattended-upgrades configuration file
sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null <<CONFIG_EOF

// Automatically upgrade packages with security fixes but leave the others untouched
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id} \${distro_codename}-security";
};

// List of packages to not automatically update
Unattended-Upgrade::Package-Blacklist {
    // "vim";
};

// Make sure mailx is installed and working
Unattended-Upgrade::Mail "$SERVER_ADMIN_EMAIL";

// Remove dependencies which are no longer required to be there
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Reboot without confirmation after a security fix has been performed that requires it
Unattended-Upgrade::Automatic-Reboot "$AUTOMATIC_OS_REBOOT";

CONFIG_EOF
