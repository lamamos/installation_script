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

package Service::pacemaker::master;

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
	if(!masterDefined($variables)){

		my $commande = masterToString($variables);

		my $fileName = "/tmp/tmp_rex_pacemaker_master.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub masterToString {

	my $variables = $_[0];

	my $commande = "ms ".$variables->{name}." ".$variables->{primitive}." ";
	if(%{$variables->{meta}}){
		$commande .= "meta ";
		foreach(keys $variables->{meta}){$commande .= $_."=\"".$variables->{meta}->{$_}."\" ";}
	}

	return $commande;
}



sub masterDefined {

	my $variables = $_[0];

	my $cib = Service::pacemaker::globfunc::getCIB();
	my @masters = Service::pacemaker::globfunc::findAll('master', $cib);

	my $exists = 0;
        foreach(@masters){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

                if(sameMaster($data, $variables)){

			$exists = 1;
                }
        }

	return $exists;
}


sub sameMaster {

	my $data = $_[0];
	my $variables = $_[1];

	if($data->{id} ne	$variables->{name}){return 0;}

	#we get the first key of the primitive hash, which is the name of the primitive of the master
	my $primitive_name = (keys $data->{primitive})[0];
	if($primitive_name ne	$variables->{primitive}){return 0;}
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
