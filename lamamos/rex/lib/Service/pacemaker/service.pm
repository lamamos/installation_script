package Service::pacemaker::service;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{name}){die "name must be defined (0 or 1).";}
	if(!defined $variables->{version}){die "version must be defined.";}

	file "/etc/corosync/service.d/".$variables->{name},
		content => template("templates/service.tpl", variables => $variables),
		owner => "root",
		group => "root",
		mode => "644";
#		on_change => sub{ service "corosync" => "restart"; };

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
