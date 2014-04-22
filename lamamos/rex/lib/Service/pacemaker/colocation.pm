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

package Service::pacemaker::colocation;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

        if(!defined $variables->{name}){die "name must be defined.";}
        if(!defined $variables->{score}){die "score must be defined.";}
	if(defined $variables->{primitives}){if(!$variables->{primitives} eq 'ARRAY'){die "primitives must be an array.";}}

	#if the primitive is not declared as the one we got in the config
	if(!colocationDefined($variables)){

		my $commande = colocationToString($variables);

		my $fileName = "/tmp/tmp_rex_pacemaker_colocation.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub colocationDefined {

        my $variables = $_[0];

        my $cib = Service::pacemaker::globfunc::getCIB();
        my @colocations = Service::pacemaker::globfunc::findAll('rsc_colocation', $cib);

	my $exists = 0;
        foreach(@colocations){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

		if(sameColocation($data, $variables)){

                        $exists = 1;
                }
        }

        return $exists;
};


sub sameColocation {

        my $data = $_[0];
        my $variables = $_[1];

        if($data->{id} ne       $variables->{name}){return 0;}
        if($data->{score} ne    $variables->{score}){return 0;}

	my $rsc = $data->{rsc};
	if(defined $data->{"rsc-role"}){$rsc .= ":".$data->{"rsc-role"};}
	my $firstPrimitive = $variables->{primitives}[0];
	if($rsc ne $firstPrimitive){return 0;}

        my $wrsc = $data->{"with-rsc"};
        if(defined $data->{"with-rsc-role"}){$wrsc .= ":".$data->{"with-rsc-role"};}
	my $secondPrimitive = $variables->{primitives}[1];
        if($wrsc ne $secondPrimitive){return 0;}

        return 1;
};


sub colocationToString {

	my $variables = $_[0];

	my $commande = "colocation ".$variables->{name}." ".$variables->{score}.": ".$variables->{primitives}[0]." ".$variables->{primitives}[1];

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
