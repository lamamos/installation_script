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

package Service::fail2ban;

use Rex -base;

task define => sub {

	install 'fail2ban';

	file "/etc/fail2ban/fail2ban.conf",
		source	=> "files/fail2ban.conf",
		owner	=> "root",
		group	=> "root",
		mode	=> "644",
		on_change	=> sub{ service "fail2ban" => "restart"; };


	file "/etc/fail2ban/jail.conf",
		source	=> "files/jail.conf",
		owner	=> "root",
		group	=> "root",
		mode	=> "644",
		on_change	=> sub{ service "fail2ban" => "restart"; };

	service fail2ban => ensure => "started";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::fail2ban/;
  
 task yourtask => sub {
    Service::fail2ban::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
