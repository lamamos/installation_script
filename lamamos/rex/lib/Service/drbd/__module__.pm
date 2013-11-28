package Service::drbd;

use Data::Dumper;
use Rex -base;

task define => sub {

	if($CFG::config{'OCFS2Init'} == "0"){

		#installSystem();
		print(areTwoServConnected());
	}

	#install 'drbd8-utils';

	#my $variables = {};
	#$variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
	#$variables->{'ddName'} = $CFG::config{'ddName'};
	#$variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        #$variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};
	#$variables->{'firstServHostName'} = $CFG::config{'firstServHostName'};
        #$variables->{'SeconServHostName'} = $CFG::config{'SeconServHostName'};

	#file "/etc/drbd.conf",
        #        content 	=> template("templates/drbd.conf.tpl", variables => $variables),
	#	owner		=> "root",
	#	group		=> "root",
	#	mode		=> "640",
	#	on_change	=> sub{ service "drbd" => "restart"; };

	#service drbd => ensure => "started";
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
	#/etc/init.d/drbd status | tail -1 | awk {'print $3'}		: SECONDARI/secondari
	#/etc/init.d/drbd status | tail -1 | awk {'print $4'}		: uptodate/uptodate




	#we now define the first serveur as primari (needed for the first synchronisation)
	if($CFG::config{'hostName'} eq $CFG::config{'firstServHostName'}){

		`drbdadm -- --overwrite-data-of-peer primary all`
	}


	#return 1;
};


sub areTwoServConnected {

	my $status1 = `/etc/init.d/drbd status | tail -1 | awk {'print \$3'} | cut --delimiter="/" -f1 | sed 's\/\\n\$\/\/'`;
        my $status2 = `/etc/init.d/drbd status | tail -1 | awk {'print \$3'} | cut --delimiter="/" -f2 | sed 's\/\\n\$\/\/'`;

	if( ($status1 eq "Unknown") || ($status2 eq "Unknown") ){

		return "stop";
	}else{

		return "ok go";
	}
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
