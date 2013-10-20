echo "=====We are going to install lamamos====="

echo "===First we install rex==="
echo 'deb http://rex.linux-files.org/debian/ wheezy rex' >> /etc/apt/sources.list
wget -O - http://rex.linux-files.org/DPKG-GPG-KEY-REXIFY-REPO | apt-key add -
apt-get update
apt-get install -y rex


echo "===Then we create a directory for lamamos configuration==="
mkdir /etc/lamamos


echo "===We copy the configuration of lamamos==="
cp -r lamamos/* /etc/lamamos/


echo "===Finaly we launch the first configuration using Rex==="
