package Service::pacemaker::primitive;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

  if(!defined $variables->{primitive_name}){die "primitive_name must be defined (0 or 1).";}
	if(!defined $variables->{primitive_class}){die "enable_secauth must be defined (0 or 1).";}
	if(!defined $variables->{primitive_type}){die "authkey_path must be defined.";}
	if(!defined $variables->{provided_by}){die "bind_address must be defined.";}
	if(defined $variables->{parameters}){if(!$variables->{parameters} eq ref {}){die "parameter must be an hash.";}}else{$variables->{parameters} = {}}
  if(defined $variables->{operations}){if(!$variables->{operations} eq ref {}){die "operations must be an hash.";}}else{$variables->{operations} = {}}

	#if the primitive is not declared as the one we got in the config
	if(!primitiveDefined($variables)){

		my $commande = primitiveToString($variables);

		say $commande;
		my $fileName = "/tmp/tmp_rex_pacemaker_primitive.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub primitiveToString {

	my $variables = $_[0];

	my $commande = "primitive ".$variables->{primitive_name}." ";
	$commande .= $variables->{primitive_class}.":".$variables->{provided_by}.":".$variables->{primitive_type};
	if(%{$variables->{parameters}}){
		$commande .= " params ";
		foreach(keys $variables->{parameters}){$commande .= $_."=\"".$variables->{parameters}->{$_}."\" ";}
	}
	if(%{$variables->{operations}}){
#		$commande .= "op ";
		foreach(keys $variables->{operations}){

			$commande .= "op ".$_." ";
			my $operations = $variables->{operations}->{$_};
			foreach(keys $operations){$commande .= $_."=\"".$operations->{$_}."\" ";}
		}
	}

	return $commande;
}



sub primitiveDefined {

	my $variables = $_[0];

	my $cib = Service::pacemaker::globfunc::getCIB();
	my @primitives = Service::pacemaker::globfunc::findAll('primitive', $cib);

	my $exists = 0;

        foreach(@primitives){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

                if(samePrimitive($data, $variables)){

			$exists = 1;
                }
        }

	return $exists;
}


sub samePrimitive {

	my $data = $_[0];
	my $variables = $_[1];

	if($data->{id} ne	$variables->{primitive_name}){return 0;}
	if($data->{class} ne	$variables->{primitive_class}){return 0;}
	if($data->{provider} ne	$variables->{provided_by}){return 0;}
	if($data->{type} ne	$variables->{primitive_type}){return 0;}
	if(!checkOperations($data, $variables)){return 0;}
	if(!checkAttributes($data, $variables)){return 0;}

	return 1;
};



sub checkOperations {

        my $data = $_[0];
        my $variables = $_[1];

	my $data_operations = $data->{operations}[0]->{op};
	if(!$data_operations){$data_operations = {}}
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
        if(!$instance_attributes){$instance_attributes = {}}
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
