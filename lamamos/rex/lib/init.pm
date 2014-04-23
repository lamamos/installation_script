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

use config;
use install;


sub initialise{

  if (my $err = ReadCfg('/etc/lamamos/lamamos.conf')) {
    print(STDERR $err, "\n");
    exit(1);
  }

  $CFG::hostName = getHostName();

  #now the config hash is in : $CFG::config{'varName'};
  #print $CFG::config{'ddName'}."\n";

  #Rex automaticaly get the new updates when launched
  #`apt-get update`;

  #we start the socket server
  communication::start();
  #communication::waitOtherServ('test', 1);

  file "/etc/cron.d/rex",
    content => "*/30 * * * * root cd /etc/lamamos/rex/ && rex configure >> /var/log/rex.log 2>&1",
    owner => "root",
    group => "root",
    mode => "644";


  #Launching of pacemaker
  installBaseSysteme();

  Service::pacemaker::primitive::define({

    'primitive_name' => 'p_ip',
    'primitive_class' => 'ocf',
    'provided_by' => 'heartbeat',
    'primitive_type' => 'IPaddr2',
    'parameters' => {'ip' => '192.168.56.100', 'cidr_netmask'=>'24', 'nic'=>'eth0',},
  });
}



sub finalise{

  #we make sure that Rex will run in 15 minutes
  #need pacemaker to be launched to work
  #Service::crontask::define({
#
#    'name' => 'Rex',
#    'minute' => '*/30',
#    'user' => 'root',
#    'commande' => 'cd /etc/lamamos/rex/ && rex configure',
#  });

  #we stop the socket server
  communication::stop({});

  #print $CFG::config{'OCFS2Init'};
  writeCfg('/etc/lamamos/lamamos.conf');
}



1;
