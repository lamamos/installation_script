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

package Service::mailman::maillinglist;

use Rex -base;
require Service::aliases;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{"name"}){die "name must be defined";}
        if(!defined $variables->{"adminAddress"}){die "adminAddress must be defined";}
        if(!defined $variables->{"password"}){die "password must be defined";}


	if(!exist($variables->{name})){

		system("newlist --quiet ".$variables->{name}." ".$variables->{adminAddress}." ".$variables->{password});

		#to make the script more readable we use a shorter variables name
		my $name = $variables->{name};

		Service::aliases::define({'source' => $name, 'destination' => '"|/var/lib/mailman/mail/mailman post '.$name.'"',});
                Service::aliases::define({'source' => $name.'-admin', 'destination' => '"|/var/lib/mailman/mail/mailman admin '.$name.'"',});
                Service::aliases::define({'source' => $name.'-bounces', 'destination' => '"|/var/lib/mailman/mail/mailman bounces '.$name.'"',});
                Service::aliases::define({'source' => $name.'-confirm', 'destination' => '"|/var/lib/mailman/mail/mailman confirm '.$name.'"',});
                Service::aliases::define({'source' => $name.'-join', 'destination' => '"|/var/lib/mailman/mail/mailman join '.$name.'"',});
                Service::aliases::define({'source' => $name.'-leave', 'destination' => '"|/var/lib/mailman/mail/mailman leave '.$name.'"',});
                Service::aliases::define({'source' => $name.'-owner', 'destination' => '"|/var/lib/mailman/mail/mailman owner '.$name.'"',});
                Service::aliases::define({'source' => $name.'-request', 'destination' => '"|/var/lib/mailman/mail/mailman request '.$name.'"',});
                Service::aliases::define({'source' => $name.'-subscribe', 'destination' => '"|/var/lib/mailman/mail/mailman subscribe '.$name.'"',});
                Service::aliases::define({'source' => $name.'-unsubscribe', 'destination' => '"|/var/lib/mailman/mail/mailman unsubscribe '.$name.'"',});

		`newaliases`;

		service "postfix" => "reload";
	}

};


sub exist {

	my $name = $_[0];

	my @list = `list_lists`;
	shift @list;

	foreach(@list){

		#we serach for the name in a case insensitive way
		if($_ =~ /$name/i){return 1;}
	}

	return 0;
}


1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::mailman/;
  
 task yourtask => sub {
    Service::mailman::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
