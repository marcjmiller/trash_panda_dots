#!/usr/bin/env bash

declare -a NEEDED_STIGS

function check_stigs() {
  printf " -> Checking STIGs... \n"

  ########## v100539 ##########
  # The Ubuntu operating system must not have the Network Information Service (NIS) package installed.
  scanout="$(dpkg -l | grep nis)"

  if [ -z "$scanout" ] || [[ "$scanout" == "nis" ]];  then
    NEEDED_STIGS+=( v100539 )
  fi

  ########## v100541 ##########
  # The Ubuntu operating system must not have the rsh-server package installed.
  scanout="$(dpkg -l | grep rsh-server)"

  if [[ "$scanout" == *rsh-server* ]];  then
    NEEDED_STIGS+=( v100541 )
  fi

  ########## v100547 ##########
  # The Ubuntu operating system must be configured to preserve log records from failure events.
  scanout="$(dpkg -l | grep rsyslog | awk '{print $2}')"

  if [ -z "$scanout" ] || [[ "$scanout" != "rsyslog" ]] ;  then
    NEEDED_STIGS+=( v100547 )
  fi

  ########## v100581 ##########
  # The Ubuntu operating system must not have the telnet package installed.
  scanout="$(dpkg -l | grep telnetd)"

  if [[ "$scanout" == *telnetd* ]];  then
    NEEDED_STIGS+=( v100581 )
  fi

  ########## v100589 ##########
  # The Ubuntu operating system must enforce a minimum 15-character password length.
  scanout="$(grep -i minlen /etc/security/pwquality.conf | awk '{print $3}')"

  if  [[ ! "$scanout" -ge 15 ]] ;  then
    NEEDED_STIGS+=( v100589 )
  fi

  ########## v100607 ##########
  # The /var/log directory must be owned by root.
  # The /var/log directory must be group-owned by root.
  scanout="$(ls -lad /var/log | cut -d ' ' -f3)"
  scanout2="$(ls -lad /var/log | cut -d ' ' -f4)"

  if [ -z "$scanout" ] || [ -z "$scanout2" ] || [[ "$scanout" != "root" ]] || [[ "$scanout2" != "root" ]];  then
    NEEDED_STIGS+=( v100607 )
  fi

  ########## v100651 ##########
  # The Ubuntu Operating system must disable the x86 Ctrl-Alt-Delete key sequence.
  scanout="$(sudo systemctl status ctrl-alt-del.target | grep Active)"

  if [[ ! "$scanout" =~ inactive ]];  then
    NEEDED_STIGS+=( v100651 )
  fi

  ########## v100839 ##########
  # The Ubuntu Operating system must disable the x86 Ctrl-Alt-Delete key sequence.
  scanout="$(grep ^Protocol /etc/ssh/sshd_config)"

  if [ -z "$scanout" ] || [[ "$scanout" != "Protocol 2" ]];  then
    NEEDED_STIGS+=( v100839 )
  fi

  ########## v100845 ##########
  # The Ubuntu operating system must immediately terminate all network connections associated with
  # SSH traffic at the end of the session or after 10 minutes of inactivity.
  scanout="$(grep -i clientaliveInterval /etc/ssh/sshd_config | awk '{print $2}')"

  if [[ ! "$scanout" -le "600" ]];  then
    NEEDED_STIGS+=( v100845 )
  fi

  ########## v100847 ##########
  # The Ubuntu operating system must configure the SSH daemon to only use Message Authentication Codes (MACs)
  # employing FIPS 140-2 approved cryptographic hash algorithms to protect the integrity of nonlocal maintenance and diagnostic communications.
  scanout="$(grep -i macs /etc/ssh/sshd_config)"

  if [ -z "$scanout" ] || [[ ! "$scanout" =~ "hmac-sha2-256" ]] || [[ ! "$scanout" =~ "hmac-sha2-512" ]];  then
    NEEDED_STIGS+=( v100847 )
  fi

  ########## v100849 ##########
  # The Ubuntu operating system must use SSH to protect the confidentiality and integrity of transmitted
  # information unless otherwise protected by alternative physical safeguards, such as, at a minimum, a Protected Distribution System (PDS).
  scanout="$(dpkg -l | grep openssh | awk '{print $2}')"

  if [[ ! "$scanout" =~ "openssh" ]] ;  then
    NEEDED_STIGS+=( v100849 )
  fi

  ########## v100851 ##########
  # The Ubuntu operating system must not allow unattended or automatic login via ssh.
  scanout="$( grep "^PermitEmptyPasswords" /etc/ssh/sshd_config)"
  scanout2="$( grep "^PermitUserEnvironment" /etc/ssh/sshd_config)"

  if [[ "$scanout" != "PermitEmptyPasswords no" ]] && [[ "$scanout2" != "PermitUserEnvironment no" ]] ;  then
    NEEDED_STIGS+=( v100851 )
  fi

  ########## v100855 ##########
  # The Ubuntu operating system must map the authenticated identity to the user or group account for PKI-based authentication.
  scanout="$(dpkg -l | grep libpam-pkcs11 | awk '{print $2}')"
  scanout2="$(grep use_mappers /etc/pam_pkcs11/pam_pkcs11.conf)"

  if [ -z "$scanout" ] || [[ "$scanout" != "libpam-pkcs11" ]] && [[ ! "$scanout2" =~ "use_mappers = pwent" ]];  then
    NEEDED_STIGS+=( v100855 )
  fi

  ########## v100861 ##########
  # The Ubuntu operating system must accept Personal Identity Verification (PIV) credentials..
  scanout="$(dpkg -l | grep opensc-pkcs11 | awk '{print $2}')"

  if [ -z "$scanout" ] || [[ ! "$scanout" =~ "opensc-pkcs11" ]] ;  then
    NEEDED_STIGS+=( v100861 )
  fi

  ########## v100911 ##########
  # The Ubuntu operating system must have an application firewall enabled.
  scanout="$(sudo systemctl status ufw.service | grep -i "active:")"
  if [[ "$scanout" =~ "inactive" ]] ;  then
    NEEDED_STIGS+=( v100911 )
  fi
}

function apply_stigs() {
  printf "   -> Applying STIGs... \n"
  for STIG in "${NEEDED_STIGS[@]}"; do
    printf "     -> %s... \n" "$STIG"
    $STIG
  done
}

v100539() {
  # The Ubuntu operating system must not have the Network Information Service (NIS) package installed.
  printf "       -> removing nis..."
  sudo apt-get -qq remove nis &
  get_status
}

v100541() {
  # The Ubuntu operating system must not have the rsh-server package installed.
  printf "       -> removing rsh-server..."
  sudo apt-get -qq remove rsh-server &
  get_status
}

v100581() {
  # The Ubuntu operating system must not have the telnet package installed.
  printf "       -> removing telnetd..."
  sudo apt-get -qq remove telnetd &
  get_status
}

v100589() {
  # The Ubuntu operating system must enforce a minimum 15-character password length.
  # If "minlen" parameter value is not 15 or higher, or is commented out, this is a finding.
  sudo sed -i 's/.*minlen =.*/minlen = 15/g' /etc/security/pwquality.conf
}

v100607() {
  # The /var/log directory must be owned by root.
  # The  /var/log directory must be group-owned by root.
  # If the /var/log directory is not owned by root, this is a finding.
  sudo chown root:root /var/log
}

v100651() {
  # The Ubuntu Operating system must disable the x86 Ctrl-Alt-Delete key sequence.
  # Configure the system to disable the Ctrl-Alt-Delete sequence for the command line with the following command:
  sudo systemctl disable ctrl-alt-del.target
  sudo systemctl mask ctrl-alt-del.target
  sudo systemctl daemon-reload
}

v100837() {
  # Ubuntu operating system must implement DoD-approved encryption to protect the confidentiality of remote access sessions.
  sudo echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
  sudo systemctl restart sshd.service
}

v100839() {
  # The Ubuntu operating system must enforce SSHv2 for network access to all accounts.
  # Configure the Ubuntu operating system to enforce SSHv2 for network access to all accounts.
  # Add or update the following line in the "/etc/ssh/sshd_config" file
  sudo echo "Protocol 2" >> /etc/ssh/sshd_config
  sudo systemctl restart sshd.service
}

v100845() {
  # The Ubuntu operating system must immediately terminate all network connections associated with
  # SSH traffic at the end of the session or after 10 minutes of inactivity.
  sudo sed -i 's/.*ClientAliveInterval .*/ClientAliveInterval 600/g' /etc/ssh/sshd_config
  sudo systemctl restart sshd.service
}


v100847() {
  # The Ubuntu operating system must configure the SSH daemon to only use Message Authentication Codes (MACs)
  # employing FIPS 140-2 approved cryptographic hash algorithms to protect the integrity of nonlocal maintenance and diagnostic communications.
  sudo echo "MACs hmac-sha2-256,hmac-sha2-512" >> /etc/ssh/sshd_config
  sudo systemctl reload sshd.service
}


v100849() {
  # The Ubuntu operating system must use SSH to protect the confidentiality and integrity of transmitted information unless otherwise protected
  # by alternative physical safeguards, such as, at a minimum, a Protected Distribution System (PDS).
  printf "       -> ssh..."
  install_package ssh &
  get_status
  sudo systemctl enable sshd.service
  sudo systemctl start sshd.service
}

v100851 () {
  # The Ubuntu operating system must not allow unattended or automatic login via ssh.
  sudo sed -i 's/.*PermitEmptyPasswords .*/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
  sudo sed -i 's/.*PermitUserEnvironment .*/PermitUserEnvironment no/g' /etc/ssh/sshd_config
  sudo sudo systemctl restart sshd.service
}

v100855() {
  # The Ubuntu operating system must not allow unattended or automatic login via ssh.
  printf "       -> libpam-pkcs11..."
  install_package libpam-pkcs11 &
  get_status
  sudo echo "use_mappers=pwent" >> /etc/pam_pkcs11/pam_pkcs11.conf
}

v100861() {
  # The Ubuntu operating system must accept Personal Identity Verification (PIV) credentials.
  printf "       -> opensc-pkcs11..."
  install_package opensc-pkcs11 &
  get_status
}
