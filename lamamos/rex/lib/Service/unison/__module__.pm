package Service::unison;

use Rex -base;

task define => sub {

	install "unison", version => "2.40.65-2";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::unison/;
  
 task yourtask => sub {
    Service::unison::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
