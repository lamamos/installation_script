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

		say "on ecrit";
		`sed -i s/START=no/START=yes/ /etc/default/corosync`;
	}

        mkdir "/var/log/cluster",
                owner   => "root",
                group   => "root",
                mode    => 644;

	service corosync => ensure => "started";

        #service pacemaker => ensure => "started";

	`/etc/init.d/pacemaker start`;

};

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
