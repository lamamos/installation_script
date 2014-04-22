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

package Service::pacemaker::group;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

        if(!defined $variables->{name}){die "name must be defined.";}
	if(defined $variables->{primitives}){if(!$variables->{primitives} eq 'ARRAY'){die "primitives must be an array.";}}

	#if the primitive is not declared as the one we got in the config
	if(!groupExists($variables->{name})){

		my $commande = groupToString($variables);

               my $fileName = "/tmp/tmp_rex_pacemaker_group.tmp";
               open(FILE, '>'.$fileName);
               print FILE $commande;
               close(FILE);

               system("crm -F configure load update ".$fileName);

	}elsif(!primitivesInGroup($variables)){

		my $commande = AddPrimitiveTogroupToString($variables);

		my $fileName = "/tmp/tmp_rex_pacemaker_primitive.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};

sub AddPrimitiveTogroupToString {

	my $variables = $_[0];
	my @primitives = @{$variables->{primitives}};
	my $groupName = $variables->{name};

	my $commande = "group ".$groupName." ";

	my @group_primitives = @{groupsPrimitives($groupName)};

	#we list all the primitive already in the group (we dont delete them)
	foreach(@group_primitives){

		$commande .= $_." ";
	}

	#we add the primitive that we have declared if they'r not in the group already
	foreach(@primitives){

		my $primitive = $_;
		if(!grep{$_ eq $primitive} @group_primitives){$commande .= $_." ";}
	}

	return $commande;
}


sub groupsPrimitives {

	my $groupName = $_[0];

        my $cib = Service::pacemaker::globfunc::getCIB();
        my @groups = Service::pacemaker::globfunc::findAll('group', $cib);

	my @primitives = ();
        foreach(@groups){

                my $group = $_;
                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($group->toString(), ForceArray => 1);

                if($data->{id} eq $groupName){

                        my @data_primitives =  $group->findnodes('primitive');
                        foreach(@data_primitives){

				push(@primitives, $_->{id});
                        }
                }
        }

        return \@primitives;	
}


sub groupExists {

        my $group_name = $_[0];

        my $cib = Service::pacemaker::globfunc::getCIB();
        my @groups = Service::pacemaker::globfunc::findAll('group', $cib);

        my $exists = 0;

        foreach(@groups){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

		if($data->{id} eq $group_name){

                        $exists = $tmp;
                }
        }

        return $exists;
};


sub groupToString {

	my $variables = $_[0];

	my $commande = "group ".$variables->{name}." ";
	foreach(@{$variables->{primitives}}){$commande .= $_." ";}

	return $commande;
}



sub primitivesInGroup {

	my $variables = $_[0];
	my $group_name = $variables->{name};
	my @primitives = @{$variables->{primitives}};

        foreach(@primitives){
		
		if(!primitiveInGroup($group_name, $_)){return 0;}
        }

        return 1;
}

sub primitiveInGroup {

	my $group_name = $_[0];
	my $primitive = $_[1];

        my $cib = Service::pacemaker::globfunc::getCIB();
        my @groups = Service::pacemaker::globfunc::findAll('group', $cib);

        foreach(@groups){

                my $group = $_;
                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($group->toString(), ForceArray => 1);

                if($data->{id} eq $group_name){

			my @data_primitives =  $group->findnodes('primitive');
			foreach(@data_primitives){

				if($_->{id} eq $primitive){return 1;}
			}
                }
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

 include qw/Service::pacemaker/;
  
 task yourtask => sub {
    Service::pacemaker::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
