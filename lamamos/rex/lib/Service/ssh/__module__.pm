package Service::ssh;

use Rex -base;

task define => sub {

	install "openssh-server";

	file "/etc/ssh/sshd_config",
		source	=> "files/sshd_config",
		owner	=> "root",
		group	=> "root",
		mode	=> "640",
		on_change	=> sub{ service "ssh" => "restart"; };

	service ssh => ensure => "started";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::ssh/;
  
 task yourtask => sub {
    Service::ssh::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
