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

package Service::resolver;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	if(!$variables->{name_servers} eq 'ARRAY'){die "the name_servers variable must be defined as an array.";}
	$variables->{domain_name} //= "";
  if(!$variables->{search_path} eq 'ARRAY'){die "the search_path variable must be defined as an array.";}


  file "/etc/resolv.conf",
	content => template("templates/resolv.conf.tpl", variables => $variables),
	owner => "root",
	group => "root",
	mode => "644";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::resolver/;
  
 task yourtask => sub {
    Service::resolver::example();
 };

=head1 ARGUMENTS

string domain_name
array string search_path
array string name_servers

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
