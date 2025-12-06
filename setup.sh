gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Raspberry Pi Kernel Builder
Name-Email: ryarnyah@gmail.com
Expire-Date: 0
EOF