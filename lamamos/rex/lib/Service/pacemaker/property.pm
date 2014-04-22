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

package Service::pacemaker::property;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

        if(!defined $variables->{name}){die "name must be defined (0 or 1).";}
	if(!defined $variables->{value}){die "value must be defined (0 or 1).";}

	#if the primitive is not declared as the one we got in the config
	if(!propertyDefined($variables)){

		my $commande = propertyToString($variables);

		my $fileName = "/tmp/tmp_rex_pacemaker_primitive.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub propertyToString {

	my $variables = $_[0];

	my $commande = "property ".$variables->{name}."=".$variables->{value};

	return $commande;
}



sub propertyDefined {

	my $variables = $_[0];

	my $cib = Service::pacemaker::globfunc::getCIB();

	my @property_set = Service::pacemaker::globfunc::findAll('cluster_property_set', $cib);


	my $exists = 0;

	my $size = @property_set;
	if($size != 0){
		my @propertys = $property_set[0]->findnodes('nvpair');	

	        foreach(@propertys){

        	        my $tmp = new XML::Simple;
                	my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

               	 if(sameProperty($data, $variables)){

				$exists = 1;
        	        }
        	}
	}
	return $exists;
}


sub sameProperty {

	my $data = $_[0];
	my $variables = $_[1];

	if($data->{name} ne	$variables->{name}){return 0;}
	if($data->{value} ne	$variables->{value}){return 0;}

	return 1;
};


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
