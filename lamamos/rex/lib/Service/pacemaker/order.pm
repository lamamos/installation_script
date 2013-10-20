package Service::pacemaker::order;

use Rex -base;
use Service::pacemaker::globfunc;
use XML::Simple;
use XML::LibXML;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

        if(!defined $variables->{name}){die "name must be defined.";}
        if(!defined $variables->{score}){die "score must be defined.";}
        if(!defined $variables->{first}){die "first must be defined.";}
        if(!defined $variables->{second}){die "second must be defined.";}

	#if the primitive is not declared as the one we got in the config
	if(!orderDefined($variables)){

		my $commande = orderToString($variables);

		say $commande;
		my $fileName = "/tmp/tmp_rex_pacemaker_colocation.tmp";
		open(FILE, '>'.$fileName);
		print FILE $commande;
		close(FILE);

		system("crm -F configure load update ".$fileName);
	}
};


sub orderDefined {

        my $variables = $_[0];

        my $cib = Service::pacemaker::globfunc::getCIB();
        my @orderss = Service::pacemaker::globfunc::findAll('rsc_order', $cib);

	my $exists = 0;
        foreach(@orderss){

                my $tmp = new XML::Simple;
                my $data = $tmp->XMLin($_->toString(), ForceArray => 1);

		if(sameOrder($data, $variables)){

                        $exists = 1;
                }
        }

        return $exists;
};


sub sameOrder {

        my $data = $_[0];
        my $variables = $_[1];

        if($data->{id} ne       $variables->{name}){return 0;}
        if($data->{score} ne    $variables->{score}){return 0;}

	my $data_first = $data->{"first"};
	if(defined $data->{"first-action"}){ $data_first .= ":".$data->{"first-action"};}
	if($data_first ne $variables->{"first"}){return 0;}

        my $data_then = $data->{"then"};
	if(defined $data->{"then-action"}){ $data_then .= ":".$data->{"then-action"};}
        if($data_then ne $variables->{second}){return 0;}

        return 1;
};


sub orderToString {

	my $variables = $_[0];

	my $commande = "order ".$variables->{name}." ".$variables->{score}.": ".$variables->{first}." ".$variables->{second};

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
