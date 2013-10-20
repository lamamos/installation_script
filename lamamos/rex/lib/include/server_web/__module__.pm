package include::server_web;

use Rex -base;
require Service::apache;
require Service::apache::vhost;
require Service::webrss2email;

task define => sub {

        Service::apache::define();

        Service::apache::vhost::define({

                'server_name'           => 'www.martobre.fr',
                'port'                  => 443,
                'server_admin'          => 'karlito@martobre.fr',
                'docroot'               => '/var/www/martobre/',
                'docroot_owner'         => 'www-data',
                'docroot_group'         => 'www-data',
                'directories'           => [
                                {'path' => '/var/www/'},
                                {'path' => '/var/www/owncloud', 'allow_override' => 'All'},
                ],
                'ssl'                   => 1,
                'ssl_cert'              => '/ssl/certificat.crt',
                'ssl_key'               => '/ssl/certificat.key',
                'redirect_match'        => 1,
                'redirections_match'    => {'^/$'       => 'https://www.martobre.fr/GDLMQT/',},
        });


        Service::apache::vhost::define({

                'server_name'           => 'jack-le-geek.martobre.fr',
                'port'                  => 80,
                'server_admin'          => 'karlito@martobre.fr',
                'docroot'               => '/var/www/jack-le-geek/',
                'docroot_owner'         => 'www-data',
                'docroot_group'         => 'www-data',
                'ssl'                   => 0,
        });

	Service::webrss2email::define();
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/include::server_web/;
  
 task yourtask => sub {
    include::server_web::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
