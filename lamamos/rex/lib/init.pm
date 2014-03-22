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


  #we stop the socket server
  communication::stop({});

  #print $CFG::config{'OCFS2Init'};
  writeCfg('/etc/lamamos/lamamos.conf');



}
