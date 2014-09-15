#!/bin/bash

#test if we are root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
fi


echo -en "\ec"
echo "=====We are going to install git====="
apt-get update
apt-get install -y git apache2-utils

echo -en "\ec"
echo "===We update the project==="
git pull

echo "===We get the submodules of the project==="
git submodule init
git submodule update






function randomString {
  # if a param was passed, it's the length of the string we want
  if [[ -n $1 ]] && [[ "$1" -lt 100 ]]; then
    local myStrLength=$1;
  else
    # otherwise set to default
    local myStrLength=8;
  fi

  local mySeedNumber=$$`date +%N`; # seed will be the pid + nanoseconds
  local myRandomString=$( echo $mySeedNumber | md5sum | md5sum );
  # create our actual random string
  myRandomResult="${myRandomString:2:myStrLength}"
}

function chooseHardDrive {

  echo "===Choose the data disk==="
  disks=`lsblk -r -o NAME,TYPE,SIZE,MOUNTPOINT|sed "1 d"`


  avalable_disks=()
  while IFS= read -r line
  do
	  name=`echo $line|cut --delimiter=" " -f1`
	  type=`echo $line|cut --delimiter=" " -f2`
	  mount=`echo $line|cut --delimiter=" " -f4`
	  size=`echo $line|cut --delimiter=" " -f3`

	  if [ "$type" == "part" ] && [ -z "$mount" ];then

		  avalable_disks+=("$name ($size)")
	  fi
  done < <(echo "$disks")	#need to be here to create a process substitution, so the variable are not erased at the end


  number_disks=${#avalable_disks[@]}

  avalable_disks+=("Quit")
  quit_number=${#avalable_disks[@]}


  PS3='On which partition must I put the data (WARNING, this partition will be formatted): '
  select opt in "${avalable_disks[@]}"
  do
	  if [ "$REPLY" -eq "$quit_number" ]; then	#if we choose to quit

		  exit
	  fi

	  if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$number_disks" ]; then

		  break
	  else
		  echo "dafuk"
	  fi
  done


  opt=`echo $opt|cut --delimiter=" " -f1`
  data_disk="/dev/$opt"

  #we ask confirmation
  echo "Your are going to format the partition $data_disk"
  read -p "Are you sure? [y/n] " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      chooseHardDrive;
  fi
}


function configureFirstServer {

  echo -en "\ec"
  echo "=== Configuration of lamamos ==="
  echo "I am going to ask you a few questions in order to configure lamamos"
  echo
  echo

  #ajouter un compteur sur le nombre de questions
  echo -n "This server hostname should be (will be set) > "
  read server1Hostname

  echo -n "This server IP is (should be already set) > "
  read server1IP

  echo
  echo

  echo -n "The second server hostname should be (will be set) > "
  read server2Hostname

  echo -n "The second server IP is (should be already set) > "
  read server2IP

  echo
  echo

  echo -n "The IP that will be shared between the servers (must be different from the two previus ones) > "
  read sharedIP

  echo
  echo

  echo -n "The password protecting the administration pannel of the server > "
  read -s adminPassw
  adminPassw=`htpasswd -n -b admin $adminPassw`
  echo

  chooseHardDrive;

  randomString 30;
}


function writeConfigToFile {

  echo "=== writting the config to the file ==="

  #just in case if the file already exists
  rm lamamos/lamamos.conf

  echo "%config = (" >> lamamos/lamamos.conf
  echo "" >> lamamos/lamamos.conf
  echo "  'drbdSharedSecret' => '$myRandomResult'," >> lamamos/lamamos.conf
  echo "  'ddName' => '$data_disk'," >> lamamos/lamamos.conf
  echo "  'OCFS2Init' => '0'," >> lamamos/lamamos.conf
  echo "  'ddFormated' => '0'," >> lamamos/lamamos.conf
  echo "  'firstServHostName' => '$server1Hostname'," >> lamamos/lamamos.conf
  echo "  'firstServIP' => '$server1IP'," >> lamamos/lamamos.conf
  echo "  'SeconServHostName' => '$server2Hostname'," >> lamamos/lamamos.conf
  echo "  'SeconServIP' => '$server2IP'," >> lamamos/lamamos.conf
  echo "  'sharedIP' => '$sharedIP'," >> lamamos/lamamos.conf
  echo "  'adminPanelPassw' => '$adminPassw'," >> lamamos/lamamos.conf
  echo ");" >> lamamos/lamamos.conf
  echo "" >> lamamos/lamamos.conf
}


function getConfigFromFirstServer {

  echo -n "What is the IP of the first server (to retrieve the configuration from it) > "
  read firstServerIP

  echo "downloading the config from the other server (you will be asked for the root password on this other server)"
  scp root@$firstServerIP:/etc/lamamos/lamamos.conf lamamos/lamamos.conf
}


function validateConfiguration {

  echo -en "\ec"
  echo "=== Here is the configuration you just entered ==="
  echo ""
  echo "The hostname of this server : $server1Hostname"
  echo "The IP of this server : $server1IP"
  echo "The hostname of the second server : $server2Hostname"
  echo "The IP of the second server : $server2IP"
  echo "The partition that will be used for datas (will be formated) : $data_disk"

  #we ask confirmation
  read -p "Is this configuration correct? [y/n] " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    configNotValidated=0;
  fi
}

echo -en "\ec"
echo "=== Configuration of lamamos ==="
echo "I am going to ask you a few questions in order to configure lamamos (7 questions)"
echo ""
echo ""

isFirstServer=0;
echo -n "Are you configurating the first server ? (if you already configured the first server, I can pull the config from it) [y/n] > "
read -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Nn]$ ]]
then
  getConfigFromFirstServer;
  isFirstServer=0;
else
  isFirstServer=1;
  configNotValidated=1;
  while [ $configNotValidated -gt 0 ]
  do
    configureFirstServer;
    validateConfiguration;
    echo -en "\ec"
  done

  #write the configuration to a file
  writeConfigToFile;
fi







getConfigParameter(){

  configParameter=`cat lamamos/lamamos.conf | grep "$1" | sed "s/\W*'$1' => '\(.*\)',/\1/"`;
}



##TODO : need to detect the right interface on wich we need to change the ip. Detect the network
#echo -en "\ec"
#echo "===We set the configured IP==="
#
#if [ $isFirstServer -gt 0 ]
#then
#  getConfigParameter firstServIP;
#else
#  getConfigParameter SeconServIP;
#fi

##add a apply configuration for the IP
#ïfconfig eth0 $configParameter






echo -en "\ec"
echo "===We set the configured hostname==="

if [ $isFirstServer -gt 0 ]
then
  getConfigParameter firstServHostName;
else
  getConfigParameter SeconServHostName;
fi

echo "$configParameter" > /etc/hostname
hostname $configParameter







echo -en "\ec"
echo "===Then we create a directory for lamamos configuration==="
mkdir /etc/lamamos


echo "===We copy the configuration of lamamos==="
cp -r lamamos/* /etc/lamamos/


echo "===We make the lamamos configuration editable by lamadmin==="
chown www-data:www-data /etc/lamamos/rex/Rexfile


echo "===We generate ssh key==="
ssh-keygen -f /root/.ssh/id_rsa -N ""
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


echo -en "\ec"
echo "===We install rex==="
echo 'deb http://rex.linux-files.org/debian/ wheezy rex' >> /etc/apt/sources.list
wget -O - http://rex.linux-files.org/DPKG-GPG-KEY-REXIFY-REPO | apt-key add -
apt-get update
apt-get install -y rex libxml-libxml-perl


echo -en "\ec"
echo "===Formating the drive==="
#We install pv in order to be able to display a progress bar of the formatting
apt-get install pv
getConfigParameter ddName;
taille=`fdisk -l $configParameter | sed -n 2p | cut -d ' ' -f 5`

dd bs=4096 if=/dev/zero | pv --size $taille | dd bs=4096 of=$configParameter


echo -en "\ec"
echo "===Copy the launching file for lamamos (launch a configure at every boot)==="
cp lamamos/lamamos /etc/init.d/
chmod 755 /etc/init.d/lamamos
update-rc.d lamamos defaults


echo -en "\ec"
echo "===Finally we launch the first configuration using Rex==="
cd /etc/lamamos/rex/
rex configure

