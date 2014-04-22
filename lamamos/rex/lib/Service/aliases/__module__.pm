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

package Service::aliases;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{source}){die "source must be defined.";}
	if(!defined $variables->{destination}){die "destination must be defined.";}

	
	#if the aliase already exist we don't do anything
	if(!redirectionExist($variables)){

		#if the source is already defined, we need to change the destination to the one we have in paramter
		if(sourceExist($variables)){

			changeDestination($variables);
		}else{	#we need to create the aliase

			createAliase($variables);
		}
	}

};

sub changeDestination {

	my $variables = $_[0];

	#we get the aliases file
        open my $file, "<", "/etc/aliases";
	my @all = <$file>;
	close $file;

        foreach(@all){

		if($_ =~ /$variables->{source}: /){

			$_ = $variables->{source}.": ".$variables->{destination}."\n";
		}
        }
	
	open FILE, ">", "/etc/aliases";
	print FILE @all;
	close FILE
}

sub createAliase {

	my $variables = $_[0];

        open my $file, ">>", "/etc/aliases";
        print $file $variables->{source}.": ".$variables->{destination}."\n";
        close $file;

        return 0;
}

sub redirectionExist {

	my $variables = $_[0];

	open ALIASES, "<", "/etc/aliases";
	while(<ALIASES>){

		if($_ =~ /$variables->{source}: $variables->{destination}/){return 1;}
	}
	close ALIASES;

	return 0;
}


sub sourceExist {

        my $variables = $_[0];

        open ALIASES, "<", "/etc/aliases";
        while(<ALIASES>){

                if($_ =~ /$variables->{source}: /){return 1;}
        }
        close ALIASES;

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
