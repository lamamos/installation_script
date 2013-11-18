package Service::drbd;

use Data::Dumper;
use Rex -base;

task define => sub {

	install 'drbd8-utils';

	my $variables = {};
	$variables->{'drbdSharedSecret'} = $CFG::config{'drbdSharedSecret'};
	$variables->{'ddName'} = $CFG::config{'ddName'};
	$variables->{'firstServIP'} = $CFG::config{'firstServIP'};
        $variables->{'SeconServIP'} = $CFG::config{'SeconServIP'};


	file "/etc/drbd.conf",
                content 	=> template("templates/drbd.conf.tpl", variables => $variables),
		owner		=> "root",
		group		=> "root",
		mode		=> "640",
		on_change	=> sub{ service "drbd" => "restart"; };

	service drbd => ensure => "started";

};

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
