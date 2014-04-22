=pod
 Copyright (C) 2013-2014 Clément Roblot

This file is part of lamamos.

Lamadmin is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Lamadmin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Lamadmin.  If not, see <http://www.gnu.org/licenses/>.
=cut

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
