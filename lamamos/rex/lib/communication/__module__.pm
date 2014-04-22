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

package communication;

use Rex -base;
use strict;
use IO::Socket;
use threads;
use threads::shared;

my $localIP = '';
my $otherServIP = '';

my $localModule = "";
my $localState = 0;

my $otherServModule = "";
my $otherServState = 0;
my $otherServUp = 1;	#we consider that the other serv is awake and running

#variable that is used for the socket
my $sock;
my $thr;




task start => sub {

  initialise();

  #definition of the listening thread
  $thr = threads->create(sub {

    #definition of the sig handlers
    $SIG{'KILL'} = sub { close($sock); threads->exit(); };


    #the socket that is used on this server to listen
    $sock = new IO::Socket::INET (
      LocalHost => $localIP,
      LocalPort => '7070',
      Proto => 'tcp',
      Listen => 1,
      Reuse => 1,
    );
    die "Could not create socket: $!\n" unless $sock;

    #we start to listen
    listener();

  });

  #we sleep 1s to wait for the sthread to be created
  sleep(1);

};


task stop => sub {

  #we kill the listening thread
  $thr->kill('KILL')->detach();
};



task waitOtherServ => sub {

  $localModule = $_[0];
  $localState = $_[1];

  sendState($localModule, $localState);

  #would be better to use some sort of a signal
  while( !(($otherServModule eq $localModule,) && ($otherServState == $localState)) ){

    sleep(1);
  };
};


sub initialise{

  if($CFG::hostName eq $CFG::config{'firstServHostName'}){$otherServIP = $CFG::config{'SeconServIP'}; $localIP = $CFG::config{'firstServIP'};}
  else{$otherServIP = $CFG::config{'firstServIP'}; $localIP = $CFG::config{'SeconServIP'};}

  #we share the variable across the threads
  share($otherServModule);
  share($otherServState);
  share($otherServUp);

  share($localModule);
  share($localState);
};





sub sendState{

  my $module = $_[0];
  my $state = $_[1];

  my $sock = new IO::Socket::INET (
    PeerAddr => $otherServIP,
    PeerPort => '7070',
    Proto => 'tcp',
  );
  if(!$sock){
    $otherServUp = 0;
    return 0;
  }
  #die "Could not create socket: $!\n" unless $sock;

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
      print "The other serv is in the state ".$otherServState." in the : ".$otherServModule." module.\n";


      #if the other serv was down befor we send back our state
      if(!$otherServUp){

        sendState($localModule, $localState);
        $otherServUp = 1;
      }
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
