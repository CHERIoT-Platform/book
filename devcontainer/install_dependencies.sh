#!/bin/bash
apt update
echo | apt-get install -y software-properties-common
add-apt-repository -y ppa:sile-typesetter/sile
apt update
echo | apt install -y git luarocks make nix
cat << EOF > /bin/sile
#!/bin/sh
nix run github:sile-typesetter/sile/v0.15.10 --extra-experimental-features nix-command --extra-experimental-features flakes --
EOF
chmod +x /bin/sile
