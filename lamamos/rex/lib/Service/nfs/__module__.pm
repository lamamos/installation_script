package Service::nfs;

use Rex -base;

task define => sub {

	install "nfs-kernel-server";

	file "/etc/exports",
		source	=> "files/exports",
		owner	=> "root",
		group	=> "root",
		mode	=> "644";

	mkdir "/data",
		owner	=> "root",
		group	=> "root",
		mode	=> 644;
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::export/;
  
 task yourtask => sub {
    Service::export::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
