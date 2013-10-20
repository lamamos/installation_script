package Service::fail2ban;

use Rex -base;

task define => sub {

	install 'fail2ban';

	file "/etc/fail2ban/fail2ban.conf",
		source	=> "files/fail2ban.conf",
		owner	=> "root",
		group	=> "root",
		mode	=> "644",
		on_change	=> sub{ service "fail2ban" => "restart"; };


	file "/etc/fail2ban/jail.conf",
		source	=> "files/jail.conf",
		owner	=> "root",
		group	=> "root",
		mode	=> "644",
		on_change	=> sub{ service "fail2ban" => "restart"; };

	service fail2ban => ensure => "started";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::fail2ban/;
  
 task yourtask => sub {
    Service::fail2ban::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
