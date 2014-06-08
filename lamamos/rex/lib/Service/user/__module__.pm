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

package Service::user;

use Rex -base;
use Rex::Commands::User;

task define => sub {

  my $variables = $_[0];

  if(!defined $variables->{name}){die "name must be defined.";}
  $variables->{home} //= "/home/".$variables->{name};
  if(!defined $variables->{password}){die "password must be defined.";}
  $variables->{shell} //= "/bin/bash";
  $variables->{system_user} //= 0;
  $variables->{no_create_home} //= 0;

  create_user $variables->{name},
    home		        => $variables->{home},
    crypt_password	=> $variables->{password},
    shell		        => $variables->{shell},
    system		      => $variables->{system_user},
    no_create_home	=> $variables->{no_create_home};

};

1;

=pod

=head1 INSTANCENAME

name

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::user/;
  
 task yourtask => sub {
    Service::user::example();
 };

=head1 ARGUMENTS

string name
string home
string password
string shell
bool system_user
bool no_create_home


=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
