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
