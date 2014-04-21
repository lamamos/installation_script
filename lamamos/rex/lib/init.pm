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
    content => "*/30 * * * * root cd /etc/lamamos/rex/ && rex configure",
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
