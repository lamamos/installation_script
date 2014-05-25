echo "=====We are going to install lamamos====="

echo "===We update the project==="
git pull

echo "===We get the submodules of the project==="
git submodule init
git submodule update

echo "===We install rex==="
echo 'deb http://rex.linux-files.org/debian/ wheezy rex' >> /etc/apt/sources.list
wget -O - http://rex.linux-files.org/DPKG-GPG-KEY-REXIFY-REPO | apt-key add -
apt-get update
apt-get install -y rex libxml-libxml-perl


echo "===Then we create a directory for lamamos configuration==="
mkdir /etc/lamamos


echo "===We copy the configuration of lamamos==="
cp -r lamamos/* /etc/lamamos/


echo "===We make the lamamos configuration editable by lamadmin==="
chown www-data:www-data /etc/lamamos/rex/Rexfile



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
done < <(printf %s "$disks" /)	#need to be here to create a process substitution, so the variable are not erased at the end


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
    exit 1
fi

#We install pv in order to be able to display a progress bar of the formatting
apt-get install pv
taille=`fdisk -l $data_disk | sed -n 2p | cut -d ' ' -f 5`


echo "===Formating the drive==="
dd bs=4096 if=/dev/zero | pv --size $taille | dd bs=4096 of=$data_disk









echo "===Finally we launch the first configuration using Rex==="
cd /etc/lamamos/rex/
rex configure

