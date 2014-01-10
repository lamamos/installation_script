package communication;

use Rex -base;
use strict;
use IO::Socket;
use threads;
use threads::shared;


my $numServer = $ARGV[0];
my $port = 7070;
my $otherServIP = '';
if($CFG::hostName eq $CFG::config{'firstServHostName'}){$otherServIP = $CFG::config{'SeconServIP'}}
else{$otherServIP = $CFG::config{'firstServIP'}}

my $otherServModule = "";
my $otherServState = 0;

#variable that is used for the socket
my $sock;
my $thr;

#we share the variable across the threads
share($otherServModule);
share($otherServState);





task start => sub {

  #definition of the listening thread
  $thr = threads->create(sub {

    #definition of the sig handlers
    $SIG{'KILL'} = sub { close($sock); threads->exit(); };


    #the socket that is used on this server to listen
    $sock = new IO::Socket::INET (
      LocalHost => '127.0.0.1',
      LocalPort => $port,
      Proto => 'tcp',
      Listen => 1,
      Reuse => 1,
    );
    die "Could not create socket: $!\n" unless $sock;

    #we start to listen
    listener();

  });
};


task stop => sub{

  #we kill the listening thread
  $thr->kill('KILL')->detach();
}



task waitOtherServ => sub {

  my $module = $_[0];
  my $state = $_[1];

  sendState($module, $state);

  #would be better to use some sort of a signal
  while( !(($otherServModule eq $module) && ($otherServState == $state)) ){

    sleep(1);
  };
};





sub sendState{

  my $module = $_[0];
  my $state = $_[1];

  my $sock = new IO::Socket::INET (
    PeerAddr => $otherServIP,
    PeerPort => '7070',
    Proto => 'tcp',
  );
  die "Could not create socket: $!\n" unless $sock;

  print $sock $module."\|".$state;
  close($sock);
};





sub listener{

  while(1){

    my $new_sock = $sock->accept(0);
    while(<$new_sock>) {

      my @values = split('\|', $_);

      $otherServModule = @values[0];
      $otherServState = @values[1];
      print "L'autre serveur est en etat ".$otherServState." sur le module : ".$otherServModule."\n";
    }
  }
};



1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::aliases/;
  
 task yourtask => sub {
    Service::aliases::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
