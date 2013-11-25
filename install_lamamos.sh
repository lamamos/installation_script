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
done < <(printf %s "$disks" /)	#need to be here to create a process subtitution, so the variable are not arased at the end


number_disks=${#avalable_disks[@]}

avalable_disks+=("Quit")
quit_number=${#avalable_disks[@]}


PS3='On wich partition must I put the data (WARNING, this partition will be formated): '
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
echo "Your are going to formate the partition $data_disk"
read -p "Are you sure? [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

#Nous installons pv pour voir l'avancement du formatage
apt-get install pv
taille=`fdisk -l $data_disk | sed -n 2p | cut -d ' ' -f 5`


echo "===Formating the drive==="
dd bs=4096 if=/dev/zero | pv --size $taille | dd bs=4096 of=$data_disk









echo "===Finaly we launch the first configuration using Rex==="
