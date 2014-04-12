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

  #we start the socket server
  communication::start();

  communication::waitOtherServ('test', 1);

  installBaseSysteme();
}



sub finalise{

  #we make sure that Rex will run in 15 minutes
  Service::crontask::define({

    'name' => 'Rex',
    'minute' => '*/30',
    'user' => 'root',
    'commande' => 'cd /etc/lamamos/rex/ && rex configure',
  });

  #we stop the socket server
  communication::stop({});

  #print $CFG::config{'OCFS2Init'};
  writeCfg('/etc/lamamos/lamamos.conf');
}



1;
