echo "=====We are going to install lamamos====="

echo "===First we install rex==="
echo 'deb http://rex.linux-files.org/debian/ wheezy rex' >> /etc/apt/sources.list
wget -O - http://rex.linux-files.org/DPKG-GPG-KEY-REXIFY-REPO | apt-key add -
apt-get update
apt-get install -y rex
