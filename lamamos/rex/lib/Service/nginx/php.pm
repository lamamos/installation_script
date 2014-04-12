package Service::nginx::php;

use Rex -base;

desc "Launch php";
task define => sub{

	install "php5-fpm";
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
