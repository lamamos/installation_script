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
