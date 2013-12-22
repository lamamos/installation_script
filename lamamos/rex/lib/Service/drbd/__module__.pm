package Service::drbd;

use Data::Dumper;
use Rex -base;

task define => sub {

	if($CFG::config{'OCFS2Init'} == "0"){

		installSystem();
		$CFG::config{'OCFS2Init'} = "1";
	}

        install ["drbd8-utils", "ocfs2-tools"];

	my $variables = {};
	$variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
	$variables->{'ddName'} = $CFG::config{'ddName'};
	$variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
	$variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

	file "/etc/drbd.conf",
                content 	=> template("templates/drbd.conf.tpl", variables => $variables),
		owner		=> "root",
		group		=> "root",
		mode		=> "640",
		on_change	=> sub{ service "drbd" => "restart"; };

	service drbd => ensure => "started";
};

sub installSystem {


	install 'drbd8-utils';

	#We consider the hard drive as zeroed out. It might be a good idea to test the assumbtion here.

	#We insert the first configuration of drbd
        my $variables = {};
        $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
        $variables->{'ddName'} = $CFG::config{'ddName'};
        $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
        $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

        file "/etc/drbd.conf",
                content         => template("templates/drbd_install_1.conf.tpl", variables => $variables),
                owner           => "root",
                group           => "root",
                mode            => "640",
                on_change       => sub{ service "drbd" => "restart"; };

	#We now create the r0 drive
	`drbdadm create-md r0`;

	#We then start drbd in order to synchronise it (we use restart in case the deamon was already running)
	#!!Certanly useless considering that the fact of changing the config file already restarted the deamon
	`/etc/init.d/drbd restart`;

	#we wait for the two servers to be connected
	while(!areTwoServConnected()){

		print("We are waitting for the other node to connect\n");
		sleep(3);
	}


	#we now define the first serveur as primari (needed for the first synchronisation)
	if($CFG::hostName eq $CFG::config{'firstServHostName'}){

		`drbdadm -- --overwrite-data-of-peer primary all`
	}


	#we then wait for the two servers to be synchronised 
	while(!areTwoServSync()){

		print("We are waitting for the two servers to synchronise.\n");
		sleep(3);
	}

	#We stop drbd, in order to configure it and enable dual primarie
	`/etc/init.d/drbd stop`;

	#we configure drbd (last config)
        my $variables = {};
        $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
        $variables->{'ddName'} = $CFG::config{'ddName'};
        $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
        $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

        file "/etc/drbd.conf",
                content         => template("templates/drbd_install_2.conf.tpl", variables => $variables),
                owner           => "root",
                group           => "root",
                mode            => "640";

	#we restart the drbd deamon
	`/etc/init.d/drbd restart`;

	#we install the soft for OCFS2
	#install 'ocfs2-tools';
        install ["ocfs2-tools", "dlm-pcmk", "ocfs2-tools-pacemaker", "openais"];

	#we format the media in OCFS2. The first server is the one that does it.
        if($CFG::hostName eq $CFG::config{'firstServHostName'}){

                `mkfs -t ocfs2 -N 2 -L ocfs2_drbd0 /dev/drbd0`;
        }

        my $variables = {};
        $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
        $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

        file "/etc/ocfs2/cluster.conf",
                content         => template("templates/cluster.conf.tpl", variables => $variables),
                owner           => "root",
                group           => "root",
                mode            => "640";

	#finaly we load the kernel modul
	#`/etc/init.d/o2cb load`;


	return 1;
};


sub areTwoServConnected {

	my $status1 = `/etc/init.d/drbd status | tail -1 | awk {'print \$3'} | cut --delimiter="/" -f1 | sed 's\/\\n\$\/\/'`;
        my $status2 = `/etc/init.d/drbd status | tail -1 | awk {'print \$3'} | cut --delimiter="/" -f2 | sed 's\/\\n\$\/\/'`;

	#the sed at the end remove the \n at the end of the string (if there is one) and it adds an \n every times.
	#That means that status1 and status2 are ended by only one \n, all the time.

	if( ($status1 eq "Unknown\n") || ($status2 eq "Unknown\n") ){

		return FALSE;
	}else{

		return TRUE;
	}
}

sub areTwoServSync {

        my $status1 = `/etc/init.d/drbd status | tail -1 | awk {'print \$4'} | cut --delimiter="/" -f1 | sed 's\/\\n\$\/\/'`;
        my $status2 = `/etc/init.d/drbd status | tail -1 | awk {'print \$4'} | cut --delimiter="/" -f2 | sed 's\/\\n\$\/\/'`;

        #the sed at the end remove the \n at the end of the string (if there is one) and it adds an \n every times.
        #That means that status1 and status2 are ended by only one \n, all the time.

        if( (($status1 eq "UpToDate\n") && ($status2 eq "UpToDate\n")) || (!areTwoServConnected()) ){

                return TRUE;
        }else{

                return FALSE;
        }
}



sub finalConfig {

        my $variables = {};
        $variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
        $variables->{'ddName'} = $CFG::config{'ddName'};
        $variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
        $variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        $variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

        file "/etc/drbd.conf",
                content         => template("templates/drbd.conf.tpl", variables => $variables),
                owner           => "root",
                group           => "root",
                mode            => "640";

}




1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::drbd/;
  
 task yourtask => sub {
    Service::drbd::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
