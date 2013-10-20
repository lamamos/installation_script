package Service::git;

use Rex -base;
use Service::user;

task define => sub {

	install "git";

	Service::user::define({

		'name'		=> 'git',
		'home'		=> '/home/git',
		'password'	=> 'WkPKy997mXsjE',
	});
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/git/;
  
 task yourtask => sub {
    git::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
