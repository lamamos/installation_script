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

package Service::crontask;

use Rex -base;
require Service::pacemaker::primitive;
require Service::pacemaker::group;
require Service::pacemaker::colocation;
require Service::pacemaker::order;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{name}){die "name must be defined.";}
	$variables->{minute} //= "*";
	$variables->{hour} //= "*";
	$variables->{day} //= "*";
	$variables->{month} //= "*";
	$variables->{day_of_week} //= "*";
        if(!defined $variables->{user}){die "user must be defined.";}
	if(!defined $variables->{commande}){die "commande must be defined.";}

        mkdir "/crontask",
                owner => "root",
                group => "root",
                mode => "644";

        file "/crontask/".$variables->{name},
                content => template("templates/crontask.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644";

	Service::pacemaker::primitive::define({

		'primitive_name' => 'p_crontask_'.$variables->{name},
		'primitive_class' => 'ocf',
		'provided_by' => 'heartbeat',
		'primitive_type' => 'symlink',
		'parameters' => {'target' => '/crontask/'.$variables->{name}, 'link' => '/etc/cron.d/'.$variables->{name}, 'backup_suffix' => '.disabled',},
		'operations' => {
			'monitor' => {
				'interval' => '20s',
				'timeout' => '30s',
			},
		},
	});

	Service::pacemaker::group::define({

		'name' => 'g_crontask',
		'primitives'	=> ['p_crontask_'.$variables->{name}],
	});

	Service::pacemaker::colocation::define({

		'name' => 'c_drbd_on_crontask',
		'score' => 'INFINITY',
		'primitives' => ['g_crontask', 'ms_p_drbd:Master'],
	});

	Service::pacemaker::order::define({

		'name' => 'o_services_crontask',
		'score' => 'INFINITY',
		'first' => 'g_services:start',
		'second' => 'g_crontask:start',
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

 include qw/Service::crontask/;
  
 task yourtask => sub {
    Service::crontask::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
