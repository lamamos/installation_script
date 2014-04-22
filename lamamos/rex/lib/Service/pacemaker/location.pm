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

package Service::pacemaker::location;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

        if(!defined $variables->{name}){die "name must be defined.";}
        if(!defined $variables->{primitive}){die "score must be defined.";}
        if(!defined $variables->{rule}){die "first must be defined.";}

	#if the primitive is not declared as the one we got in the config
	if(!locationDefined($variables)){

		my $commande = locationToString($variables);

		my $fileName = "/tmp/tmp_rex_pacemaker_location.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		say "system";
		system("crm -F configure load update ".$fileName);
	}
};


sub locationDefined {

        my $variables = $_[0];

        my $cib = Service::pacemaker::globfunc::getCIB();
        my @locations = Service::pacemaker::globfunc::findAll('rsc_location', $cib);

	my $exists = 0;
        foreach(@locations){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

		if(sameLocation($data, $variables)){

                        $exists = 1;
                }
        }

        return $exists;
};


sub sameLocation {

        my $data = $_[0];
        my $variables = $_[1];

        if($data->{id} ne	$variables->{name}){return 0;}
        if($data->{rsc} ne	$variables->{primitive}){return 0;}

	my $xml_rule = (keys $data->{rule})[0];
	$xml_rule = $data->{rule}->{$xml_rule};

	my $rule = "\$role=\"".$xml_rule->{role}."\" ".$xml_rule->{score}.": ";

	my @expressions = keys $xml_rule->{expression};
	my $compteur = 0;
	for(@expressions){

		$compteur = $compteur +1;

		if($xml_rule->{expression}->{$_}->{operation} eq "not_defined"){


			$rule .= $xml_rule->{expression}->{$_}->{operation}." ".$xml_rule->{expression}->{$_}->{attribute};
		}else{

			$rule .= $xml_rule->{expression}->{$_}->{attribute}." ".$xml_rule->{expression}->{$_}->{type}.":".$xml_rule->{expression}->{$_}->{operation}." ".$xml_rule->{expression}->{$_}->{value};
		}

		if($compteur != @expressions){

			if(defined $xml_rule->{"boolean-op"}){$rule .= " ".$xml_rule->{"boolean-op"}." ";}
		}
	}

	if($rule ne $variables->{rule}){return 0;}

        return 1;
};


sub locationToString {

	my $variables = $_[0];

	my $commande = "location ".$variables->{name}." ".$variables->{primitive}." rule ".$variables->{rule};

	return $commande;
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
