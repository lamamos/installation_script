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

package Service::lamadmin;

use Rex -base;
require Service::apache;
require Service::apache::vhost;

task define => sub {

	my $variables = $_[0];
  if(!defined $variables->{install_path}){die "install_path must be defined.";}

  mkdir $variables->{install_path},
    owner => "www-data",
    group => "www-data",
    mode  => 755;

  `cp -r /etc/lamamos/rex/lib/Service/lamadmin/files/lamadmin/* $variables->{install_path}`;
  `echo $CFG::config{'adminPanelPassw'} > $variables->{install_path}/.htpasswd`;

};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::webrss2email/;
  
 task yourtask => sub {
    Service::webrss2email::example();
 };

=head1 ARGUMENTS

string install_path



=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
