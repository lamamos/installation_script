package Service::mysql;

use Rex -base;
require Service::pacemaker;
require Service::pacemaker::clone;
require Service::pacemaker::colocation;
require Service::pacemaker::globfunc;
require Service::pacemaker::group;
require Service::pacemaker::location;
require Service::pacemaker::master;
require Service::pacemaker::order;
require Service::pacemaker::primitive;
require Service::pacemaker::property;
require Service::pacemaker::rsc_defaults;
require Service::pacemaker::service;

task define => sub {

  my $variables = $_[0];

  $variables->{socket_file}	//= "/var/run/mysqld/mysqld.sock";
  $variables->{pid_file}	//= "/var/run/mysqld/mysqld.pid";

  install ["mysql-server", "php5-mysql"];

  file "/etc/mysql/my.cnf",
    content => template("templates/my.cnf.tpl", variables => $variables),
    owner => "root",
    group => "root",
    mode => "644",
    on_change => sub{ service "mysql" => "restart"; };

  Service::pacemaker::primitive::define({

    'primitive_name' => 'p_mysql',
    'primitive_class' => 'ocf',
    'provided_by' => 'heartbeat',
    'primitive_type' => 'mysql',
    'parameters' => {'binary'=>'/usr/sbin/mysqld', 'config'=>'/etc/mysql/my.cnf', 'datadir'=>'/var/lib/mysql', 'pid'=>$variables->{pid_file}, 'socket'=>$variables->{socket_file}, },
  });

  Service::pacemaker::colocation::define({

    'name' => 'colPrimaryMYSQL',
    'score' => 'INFINITY',
    'primitives' => ['p_ip', 'p_mysql'],
  });

  Service::pacemaker::order::define({

    'name' => 'ordPrimaryMYSQL',
    'score' => '0',
    'first' => 'p_ip:start',
    'second' => 'p_mysql:start',
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

 include qw/Service::mysql/;
  
 task yourtask => sub {
    Service::mysql::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
