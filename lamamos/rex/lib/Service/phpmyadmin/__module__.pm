package Service::phpmyadmin;

use Rex -base;
require Service::apache::vhost;


task define => sub {

	install "phpmyadmin";

        Service::apache::vhost::define({

                'server_name'           => 'phpmyadmin.martobre.fr',
                'port'                  => 443,
                'server_admin'          => 'karlito@martobre.fr',
                'docroot'               => '/usr/share/phpmyadmin',
                'manage_folder'         => 0,
                'ssl'                   => 1,
                'ssl_cert'              => '/ssl/certificat.crt',
                'ssl_key'               => '/ssl/certificat.key',
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

 include qw/Service::phpmyadmin/;
  
 task yourtask => sub {
    Service::phpmyadmin::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
