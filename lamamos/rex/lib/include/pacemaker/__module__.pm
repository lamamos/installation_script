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

package include::pacemaker;

use Rex -base;
require Service::pacemaker;
require Service::pacemaker::service;
require Service::pacemaker::primitive;
require Service::pacemaker::master;
require Service::pacemaker::property;
require Service::pacemaker::rsc_defaults;
require Service::pacemaker::group;
require Service::pacemaker::colocation;
require Service::pacemaker::order;
require Service::pacemaker::clone;
require Service::pacemaker::location;

task define => sub {



	Service::pacemaker::define({

		'enable_secauth'	=> 1,
		'authkey_path'		=> '/etc/corosync/authkey',
		'bind_address'		=> '192.168.0.0',
		'multicast_address'	=> '226.99.5.1',
	});


	Service::pacemaker::service::define({

		'name'		=> 'pacemaker',
		'version'	=> '1',
	});


        Service::pacemaker::property::define({

                'name'  => 'no-quorum-policy',
                'value' => 'ignore',
        });

        Service::pacemaker::property::define({

                'name'  => 'stonith-enabled',
                'value' => 'false',
        });

	Service::pacemaker::rsc_defaults::define({

		'name' => 'resource-stickiness',
		'value' => '100',
	});

########################################

	Service::pacemaker::primitive::define({

		'primitive_name' => 'p_drbd',
		'primitive_class' => 'ocf',
		'primitive_type' => 'drbd',
		'provided_by' => 'linbit',
		'parameters' => {'drbd_resource' => 'r0',},
		'operations' => {'monitor' => {'interval' => '15s',},},
	});


	Service::pacemaker::master::define({

		'name' => 'ms_p_drbd',
		'primitive' => 'p_drbd',
		'meta' => {
			'master-max' => '1',
			'master-node-max' => '1',
			'clone-max' => '2',
			'clone-node-max' => '1',
			'notify' => 'true',
		},
	});

########################################


	Service::pacemaker::primitive::define({

                'primitive_name' => 'p_fs',
                'primitive_class' => 'ocf',
                'provided_by' => 'heartbeat',
                'primitive_type' => 'Filesystem',
                'parameters' => {'device' => '/dev/drbd0', 'directory' => '/data', 'fstype' => 'ext4',},
        });


        Service::pacemaker::primitive::define({

                'primitive_name' => 'p_ip',
                'primitive_class' => 'ocf',
                'provided_by' => 'heartbeat',
                'primitive_type' => 'IPaddr2',
                'parameters' => {'ip' => '192.168.0.200', 'cidr_netmask' => '24', 'nic' => 'eth0',},
        });

	Service::pacemaker::group::define({

		'name' => 'g_fs_ip',
		'primitives' => ['p_fs', 'p_ip'],
	});


	Service::pacemaker::colocation::define({

		'name' => 'c_drbd_on_fs',
		'score' => 'INFINITY',
		'primitives' => ['g_fs_ip', 'ms_p_drbd:Master'],
	});


	Service::pacemaker::order::define({

		'name' => 'o_drbd_fs',
		'score' => 'INFINITY',
		'first' => 'ms_p_drbd:promote',
		'second' => 'g_fs_ip:start',
	});


########################################


        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_home',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/home', 'directory' => '/home', 'fstype' => 'nfs',},
        });


        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_www',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/www', 'directory' => '/var/www', 'fstype' => 'nfs',},
        });


        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_manifests',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/manifests', 'directory' => '/etc/puppet/manifests', 'fstype' => 'nfs',},
        });

        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_modules',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/modules', 'directory' => '/etc/puppet/modules', 'fstype' => 'nfs',},
        });

        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_ssl',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/ssl', 'directory' => '/ssl', 'fstype' => 'nfs',},
        });

        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_rex',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/rex', 'directory' => '/rex', 'fstype' => 'nfs',},
        });

        Service::pacemaker::primitive::define({

                'primitive_name'        => 'p_nfs_crontask',
                'primitive_class'       => 'ocf',
                'provided_by'           => 'heartbeat',
                'primitive_type'        => 'Filesystem',
                'parameters'            => {'device' => '192.168.0.200:/data/crontask', 'directory' => '/crontask', 'fstype' => 'nfs',},
        });

        Service::pacemaker::group::define({

                'name' => 'g_nfs',
                'primitives' => ['p_nfs_home', 'p_nfs_www', 'p_nfs_manifests', 'p_nfs_modules', 'p_nfs_ssl', 'p_nfs_rex', 'p_nfs_crontask'],
        });

	Service::pacemaker::clone::define({

                'name' => 'cl_nfs',
                'primitive' => 'g_nfs',
                'meta' => {'interleave' => 'true',},
        });

        Service::pacemaker::order::define({

                'name' => 'o_drbd_nfs',
                'score' => 'INFINITY',
                'first' => 'g_fs_ip:start',
                'second' => 'cl_nfs:start',
        });

########################################

#        Service::pacemaker::primitive::define({
#
#                'primitive_name' => 'p_apache',
#                'primitive_class' => 'ocf',
#                'provided_by' => 'heartbeat',
#                'primitive_type' => 'apache',
#                'parameters' => {'configfile' => '/etc/apache2/apache2.conf',},
#                'operations' => {
#                        'monitor' => {
#                                'interval' => '30s',
#                                'timeout' => '30s',
#                        },
#                        'start' => {
#                                'interval' => '0s',
#                                'timeout' => '120s',
#                        },
#                        'stop' => {
#                                'interval' => '0',
#                                'timeout' => '120s',
#                        },
#                },
#        });


	Service::pacemaker::primitive::define({

		'primitive_name' => 'p_mysql',
		'primitive_class' => 'ocf',
		'provided_by' => 'heartbeat',
		'primitive_type' => 'mysql',
		'parameters' => {'datadir' => '/data/mysql/data', 'pid' => '/data/mysql/config/mysql.pid', 'socket' => '/data/mysql/config/mysql.sock',},
		'operations' => {
			'monitor' => {
				'interval' => '20s',
				'timeout' => '30s',
			},
			'start' => {
				'interval' => '0s',
				'timeout' => '120s',
			},
			'stop' => {
				'interval' => '0',
				'timeout' => '120s',
			},
		},
	});

        Service::pacemaker::primitive::define({

                'primitive_name' => 'p_postfix',
                'primitive_class' => 'ocf',
                'provided_by' => 'heartbeat',
                'primitive_type' => 'postfix',
                'operations' => {
                        'monitor' => {
                                'interval' => '30s',
                                'timeout' => '30s',
                        },
                },
        });


	Service::pacemaker::group::define({

		'name' => 'g_services',
#		'primitives' => ['p_apache', 'p_mysql', 'p_postfix'],
		'primitives'	=> ['p_mysql', 'p_postfix'],
	});

	Service::pacemaker::colocation::define({

		'name' => 'c_drbd_on_services',
		'score' => 'INFINITY',
		'primitives' => ['g_services', 'ms_p_drbd:Master'],
	});

	Service::pacemaker::order::define({

		'name' => 'o_drbd_services',
		'score' => 'INFINITY',
		'first' => 'cl_nfs:start',
		'second' => 'g_services:start',
	});

########################################


	Service::pacemaker::primitive::define({

		'primitive_name' => 'p_ping',
		'primitive_class' => 'ocf',
		'provided_by' => 'pacemaker',
		'primitive_type' => 'ping',
		'parameters' => {'name' => 'ping', 'multiplier' => '75', 'host_list' => '192.168.0.254 192.168.0.150 192.168.0.151',},
		'operations' => {
			'monitor' => {

				'interval' => '15s',
				'timeout' => '60s',
			},
			'start' => {

				'interval' => '0s',
				'timeout' => '60s',
			},
		},
	});


        Service::pacemaker::clone::define({

                'name' => 'cl_ping',
                'primitive' => 'p_ping',
                'meta' => {'interleave' => 'true',},
        });

	Service::pacemaker::location::define({

		'name' => 'l_drbd_master_on_ping',
		'primitive' => 'ms_p_drbd',
		'rule' => '$role="master" -INFINITY: not_defined ping or ping number:lte 100',
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

 include qw/include::pacemaker/;
  
 task yourtask => sub {
    include::pacemaker::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
