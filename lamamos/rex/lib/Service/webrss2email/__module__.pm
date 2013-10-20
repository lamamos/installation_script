package Service::webrss2email;

use Rex -base;
require Service::apache::vhost;
require Service::crontask;

task define => sub {

	my $variables = $_[0];

#	my $path = "/var/www/webrss2email";
#
#
#	mkdir $path,
#		owner	=> "www-data",
#		group	=> "www-data",
#		mode	=> 755;
#
#	`tar -xvf files/webrss2email.tar.gz -C $path`;


	install "libapache2-mod-python";


        Service::apache::vhost::define({

		'file_name'	=> 'webrss2email',
                'server_name' => 'www.martobre.fr/webrss2email',
                'port' => 80,
                'server_admin' => 'karlito@martobre.fr',
                'docroot' => '/var/www/webrss2email/',
                'docroot_owner' => 'www-data',
                'docroot_group' => 'www-data',
                'ssl' => 0,
        });


	Service::crontask::define({

		'name'		=> 'webrss2email',
		'minute'	=> '*/15',
		'hour'		=> '*',
		'day'		=> '*',
		'month'		=> '*',
		'day_of_week'	=> '*',
		'user'		=> 'root',
		'commande'	=> '/var/www/webrss2email/cron.py',
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

 include qw/Service::webrss2email/;
  
 task yourtask => sub {
    Service::webrss2email::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
