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

package Service::pacemaker::globfunc;

use Rex -base;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;


sub getCIB {

	my $CIB = `crm configure show xml`;
        my $data = XML::LibXML->load_xml(string => $CIB);
	return $data;
};


sub findAll {

	my $exp = $_[0];
	my $xml = $_[1];

	my @configuration = $xml->findnodes('/cib/configuration');
	my $config = $configuration[0];	

	my $node = $config->firstChild;

        my @matchs = ();
	while ($node = $node->nextNonBlankSibling){

		push(@matchs, subFindAll($exp, $node));
	}

	return @matchs;
};


sub subFindAll {

        my $exp = $_[0];
        my $root = $_[1];

	#if we have whate we are looking for, we return it.
	if($root->nodeName eq $exp){

		return ($root);
	}

	#if not we shearch in all it's childs
	my $child = $root->firstChild;

	my @matchs = ();
	if($child){
		while($child = $child->nextNonBlankSibling){

			push(@matchs, subFindAll($exp, $child));
		}
	}

	return @matchs;
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
