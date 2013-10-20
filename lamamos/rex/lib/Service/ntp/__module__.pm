package Service::ntp;

use Rex -base;

task define => sub {

	install "ntp";

	file "/etc/ntp.conf",
		source	=> "files/ntp.conf",
		owner	=> "root",
		group	=> "root",
		mode	=> "640",
		on_change	=> sub{ service "ntp" => "restart"; };

	service ntp => ensure => "started";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::ntp/;
  
 task yourtask => sub {
    Service::ntp::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
