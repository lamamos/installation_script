=pod
 Copyright (C) 2013-2014 Clément Roblot

This file is part of lamamos.

Lamadmin is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Lamadmin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Lamadmin.  If not, see <http://www.gnu.org/licenses/>.
=cut

package Service::pacemaker;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{enable_secauth}){die "enable_secauth must be defined (0 or 1).";}
	if(!defined $variables->{authkey_path}){die "authkey_path must be defined.";}
	if(!defined $variables->{bind_address}){die "bind_address must be defined.";}
	if(!defined $variables->{multicast_address}){die "multicast_address must be defined.";}

	#install [qw/pacemaker corosync/];
	install "corosync";
	install "pacemaker";

	file "/etc/corosync/authkey",
		source => "/etc/lamamos/authkey",
		owner => "root",
		group => "root",
		mode => "500";


	file "/etc/corosync/corosync.conf",
		content => template("templates/corosync.conf.tpl", variables => $variables),
		owner => "root",
		group => "root",
		mode => "644";
#		on_change => sub{ service "corosync" => "restart"; };

	mkdir "/etc/corosync/service.d",
		owner	=> "root",
		group	=> "root",
		mode	=> 755;

	if(!`grep START=yes /etc/default/corosync`){

		`sed -i s/START=no/START=yes/ /etc/default/corosync`;
	}

        mkdir "/var/log/cluster",
                owner   => "root",
                group   => "root",
                mode    => 644;



	#before launching pacemaker and corosync we stop all the services that they are going to manage
	`update-rc.d drbd remove`;
        `update-rc.d ocfs2 remove`;
        `update-rc.d o2cb remove`;

	`/etc/init.d/o2cb stop`;



	service corosync => ensure => "started";

        #service pacemaker => ensure => "started";

	`/etc/init.d/pacemaker start`;

};



sub waitForTwoServToConnect{

  while(!areTwoServConnectedToPacemaker()){

	  #the two servers are connected
	  print "We are waitting for the two servers to connect to pacemaker.\n";
	  sleep(3);	
  }
};


sub areTwoServConnectedToPacemaker {

  my $status1 = `crm node show | grep \"$CFG::config{'firstServHostName'}\" | cut --delimiter=":" -f2 | sed 's/ //g'`;
  my $status2 = `crm node show | grep \"$CFG::config{'SeconServHostName'}\" | cut --delimiter=":" -f2 | sed 's/ //g'`;

  if( ($status1 eq "normal\n") && ($status2 eq "normal\n") ){

    #the two servers are connected
		return TRUE;
  }else{

		return FALSE;
	}
}

sub isPacemakerRunning {

  my $status = `/etc/init.d/drbd status | grep \"is running...\" | wc -l`;

  if($status eq "0"){

    return FALSE;
  }else{

    return TRUE;
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

 include qw/Service::pacemaker/;
  
 task yourtask => sub {
    Service::pacemaker::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
