package Service::mysql;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	$variables->{socket_file}	//= "/var/run/mysqld/mysqld.sock";
	$variables->{pid_file}	//= "/var/run/mysqld/mysqld.pid";

	install ["mysql-server", "php5-mysql"];

	file "/etc/mysql/my.cnf",
		content => template("templates/my.cnf.tpl", variables => $variables),
		owner => "root",
		group => "root",
		mode => "644",
		on_change => sub{ service "mysql" => "reload"; };
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::mysql/;
  
 task yourtask => sub {
    Service::mysql::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
