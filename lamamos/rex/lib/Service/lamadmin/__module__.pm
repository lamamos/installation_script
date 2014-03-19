package Service::lamadmin;

use Rex -base;
require Service::apache;
require Service::apache::vhost;

task define => sub {

	my $variables = $_[0];
  if(!defined $variables->{install_path}){die "install_path must be defined.";}

  mkdir $variables->{install_path},
    owner => "www-data",
    group => "www-data",
    mode  => 755;

  `tar -xvf files/lamadmin.tar.gz -C $variables->{install_path}`;
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::webrss2email/;
  
 task yourtask => sub {
    Service::webrss2email::example();
 };

=head1 ARGUMENTS

string install_path



=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
