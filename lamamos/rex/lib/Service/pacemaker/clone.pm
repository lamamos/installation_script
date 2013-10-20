package Service::pacemaker::clone;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

        if(!defined $variables->{name}){die "name must be defined (0 or 1).";}
	if(!defined $variables->{primitive}){die "primitive must be defined (0 or 1).";}
	if(defined $variables->{meta}){if(!$variables->{meta} eq ref {}){die "meta must be an hash.";}}else{$variables->{meta} = {}}

	#if the primitive is not declared as the one we got in the config
	if(!cloneDefined($variables)){

		my $commande = cloneToString($variables);

		say $commande;
		my $fileName = "/tmp/tmp_rex_pacemaker_clone.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub cloneToString {

	my $variables = $_[0];

	my $commande = "clone ".$variables->{name}." ".$variables->{primitive}." ";
	if(%{$variables->{meta}}){
		$commande .= "meta ";
		foreach(keys $variables->{meta}){$commande .= $_."=\"".$variables->{meta}->{$_}."\" ";}
	}

	return $commande;
}



sub cloneDefined {

	my $variables = $_[0];

	my $cib = Service::pacemaker::globfunc::getCIB();
	my @clones = Service::pacemaker::globfunc::findAll('clone', $cib);

	my $exists = 0;
        foreach(@clones){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

                if(sameClone($data, $variables)){

			$exists = 1;
                }
        }

	return $exists;
}


sub sameClone {

	my $data = $_[0];
	my $variables = $_[1];

	if($data->{id} ne	$variables->{name}){return 0;}

	#we get the key which is not the id nor the meta datas. (we search for the primitive or the group which is cloned)
	my %copie_data = %{$data};
	delete %copie_data->{id};
	delete %copie_data->{meta_attributes};
	my $resource_type = (keys %copie_data)[0];

	my $resource = $data->{$resource_type};
	my $resource_name = (keys $resource)[0];

	if($resource_name ne	$variables->{primitive}){return 0;}

	if(!checkMeta($data, $variables)){return 0;}

	return 1;
};



sub checkMeta {

        my $data = $_[0];
        my $variables = $_[1];

	my $root_metas = $data->{meta_attributes};
	my $master_metas_name = (keys $root_metas)[0];
	my $data_metas = $root_metas->{$master_metas_name}->{nvpair};
	if(!$data_metas){$data_metas = {}}
	my $variables_metas = $variables->{meta};

	my $nbr_data_metas = keys $data_metas;
	my $nbr_variables_metas = keys $variables_metas;
	if($nbr_data_metas != $nbr_variables_metas){return 0;}
	for(keys $data_metas){

		#we check if the key was defined in the parameters
		if(!defined $variables_metas->{$_}){return 0;}

		my $data_meta = $data_metas->{$_}->{value};
		my $variables_meta = $variables_metas->{$_};

		if($data_meta ne $variables_meta){return 0;}
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
