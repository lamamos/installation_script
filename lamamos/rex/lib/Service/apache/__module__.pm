package Service::apache;

use Rex -base;


desc "Start Apache Service";
task define => sub {

	install "apache2";

	file "/etc/apache2/httpd.conf",
		source		=> "files/httpd.conf",
		owner		=> "root",
		group		=> "root",
		mode		=> "644",
		on_change	=> sub{ service "apache2" => "reload"; };

	service apache2 => ensure => "started";
};



1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::apache/;
  
 task yourtask => sub {
    Service::apache::example();
 };

=head1 ARGUMENTS


=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
