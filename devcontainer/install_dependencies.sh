apt update
echo | apt-get install -y software-properties-common
add-apt-repository -y ppa:sile-typesetter/sile
apt update
echo | apt install -y git wget luarocks make 
cd /tmp
wget https://launchpad.net/~sile-typesetter/+archive/ubuntu/sile/+build/30575828/+files/sile_0.15.10-1ppa1~ubuntu24.04_amd64.deb
dpkg -i ./sile_0.15.10-1ppa1~ubuntu24.04_amd64.deb
apt -fy install
dpkg -i ./sile_0.15.10-1ppa1~ubuntu24.04_amd64.deb
