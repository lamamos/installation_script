package Service::apache::php;

use Rex -base;



desc "create a new vhost";
task define => sub{

	install "libapache2-mod-php5";
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

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
