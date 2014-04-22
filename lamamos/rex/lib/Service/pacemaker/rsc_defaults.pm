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

package Service::pacemaker::rsc_defaults;

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
	if(!rscDefined($variables)){

		my $commande = rscDefaultToString($variables);

		my $fileName = "/tmp/tmp_rex_pacemaker_rsc_default.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub rscDefaultToString {

	my $variables = $_[0];

	my $commande = "rsc_defaults ".$variables->{name}."=".$variables->{value};

	return $commande;
}



sub rscDefined {

	my $variables = $_[0];

	my $cib = Service::pacemaker::globfunc::getCIB();

	my @rsc_defaults = Service::pacemaker::globfunc::findAll('rsc_defaults', $cib);

	my $size = @rsc_defaults;

        my $exists = 0;
	if($size != 0){
	
		my @attributes = $rsc_defaults[0]->findnodes('meta_attributes');	
		my @values = $attributes[0]->findnodes('nvpair');
	
	        foreach(@values){

	                my $tmp = new XML::Simple;
	                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

	                if(sameRscDefault($data, $variables)){

				$exists = 1;
	                }
	        }
	}

	return $exists;
}


sub sameRscDefault {

	my $data = $_[0];
	my $variables = $_[1];

	if($data->{name} ne	$variables->{name}){return 0;}
	if($data->{value} ne	$variables->{value}){return 0;}

	return 1;
};



sub checkOperations {

        my $data = $_[0];
        my $variables = $_[1];

	my $data_operations = $data->{operations}[0]->{op};
	my $variables_operations = $variables->{operations};

	#parser monitor, start, stop etc...
	my $nbr_data_operations = keys $data_operations;
	my $nbr_variables_operations = keys $variables_operations;
	if($nbr_data_operations != $nbr_variables_operations){return 0;}
	for(keys $data_operations){

		#we check if the key was defined in the parameters
		if(!defined $variables_operations->{$_}){return 0;}

		my $data_op = $data_operations->{$_};
		my $variables_op = $variables_operations->{$_};

		#minus one because we dont care aboute the id
		my $nbr_data_op = keys $data_op;
		$nbr_data_op = $nbr_data_op - 1;
		my $nbr_variables_op = keys $variables_op;
		if($nbr_data_op != $nbr_variables_op){return 0;}

		for(keys $data_operations->{$_}){

			if($_ eq 'id'){next;}
			if(!defined $variables_op->{$_}){return 0;}

			if($data_op->{$_} ne $variables_op->{$_}){return 0;}
		}
	}

	return 1;
};

sub checkAttributes {

	my $data = $_[0];
	my $variables = $_[1];

	my $parameters = $variables->{parameters};
	my $nbr_paramaters = keys $parameters;


	#on doit lister tout dans nvpair
	my $instance_attributes = $data->{'instance_attributes'};
	for(keys $instance_attributes){

		my $nvpairs = $instance_attributes->{$_}->{nvpair};

		#we check if we have the same numbers of paramters
		my @keys = keys $nvpairs;
		my $nbr_keys = @keys;
		if($nbr_keys != $nbr_paramaters){return 0;}
		for(keys $nvpairs){
			
			#we check if the key was defined in the parameters
			if(!defined $parameters->{$_}){return 0;}
			#we check if the values are the same
			if($nvpairs->{$_}->{value} ne $parameters->{$_}){return 0;}
		}
	}

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
