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
