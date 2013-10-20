package include::bdd;

use Rex -base;
require Service::mysql;
require Service::phpmyadmin;

task define => sub {

        Service::mysql::define();
        Service::phpmyadmin::define();
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/bdd/;
  
 task yourtask => sub {
    bdd::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
