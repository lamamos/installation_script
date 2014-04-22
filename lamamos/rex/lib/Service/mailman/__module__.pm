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

package Service::mailman;

use Rex -base;

require Service::mailman::maillinglist;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{"mailDomain"}){die "mailDomain must be defined";}
        if(!defined $variables->{"vhostAddress"}){die "hostname must be defined";}


	install "mailman";

	mkdir "/var/www/lists",
		owner	=> "www-data",
		group	=> "www-data",
		mode	=> 755; 

        file "/etc/mailman/mm_cfg.py",
                content => template("templates/mm_cfg.py.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "mailman" => "reload"; };

        file "/etc/apache2/sites-enabled/mailman.cfg",
                content => template("templates/apache.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "apache2" => "reload"; };

	Service::mailman::maillinglist::define({

		'name'		=> 'mailman',
		'adminAddress'	=> 'karlito@martobre.fr',
		'password'	=> 'yzZxX0_p',
	});

        Service::mailman::maillinglist::define({

                'name'          => 'mailman-list',
                'adminAddress'  => 'karlito@martobre.fr',
                'password'      => 'yzZxX0_p',
        });

	service => "mailman" => "start";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::mailman/;
  
 task yourtask => sub {
    Service::mailman::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
