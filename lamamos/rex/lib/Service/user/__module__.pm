package Service::user;

use Rex -base;
use Rex::Commands::User;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{name}){die "name must be defined.";}
	$variables->{home} //= "/home/".$variables->{name};
  if(!defined $variables->{password}){die "password must be defined.";}
	$variables->{shell} //= "/bin/bash";
	$variables->{systeme} //= 0;
	$variables->{no_create_home} //= 0;

	create_user $variables->{name},
		home		=> $variables->{home},
		crypt_password	=> $variables->{password},
		shell		=> $variables->{shell},
		system		=> $variables=>{system},
		no_create_home	=> $variables->{no_create_home};

};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::user/;
  
 task yourtask => sub {
    Service::user::example();
 };

=head1 ARGUMENTS

string name
string home
string password
string shell
bool systeme
bool no_create_home


=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
