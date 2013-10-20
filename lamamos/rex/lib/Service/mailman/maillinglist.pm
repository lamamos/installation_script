package Service::mailman::maillinglist;

use Rex -base;
require Service::aliases;

task define => sub {

	my $variables = $_[0];

	if(!defined $variables->{"name"}){die "name must be defined";}
        if(!defined $variables->{"adminAddress"}){die "adminAddress must be defined";}
        if(!defined $variables->{"password"}){die "password must be defined";}


	if(!exist($variables->{name})){

		system("newlist --quiet ".$variables->{name}." ".$variables->{adminAddress}." ".$variables->{password});

		#to make the script more readable we use a shorter variables name
		my $name = $variables->{name};

		Service::aliases::define({'source' => $name, 'destination' => '"|/var/lib/mailman/mail/mailman post '.$name.'"',});
                Service::aliases::define({'source' => $name.'-admin', 'destination' => '"|/var/lib/mailman/mail/mailman admin '.$name.'"',});
                Service::aliases::define({'source' => $name.'-bounces', 'destination' => '"|/var/lib/mailman/mail/mailman bounces '.$name.'"',});
                Service::aliases::define({'source' => $name.'-confirm', 'destination' => '"|/var/lib/mailman/mail/mailman confirm '.$name.'"',});
                Service::aliases::define({'source' => $name.'-join', 'destination' => '"|/var/lib/mailman/mail/mailman join '.$name.'"',});
                Service::aliases::define({'source' => $name.'-leave', 'destination' => '"|/var/lib/mailman/mail/mailman leave '.$name.'"',});
                Service::aliases::define({'source' => $name.'-owner', 'destination' => '"|/var/lib/mailman/mail/mailman owner '.$name.'"',});
                Service::aliases::define({'source' => $name.'-request', 'destination' => '"|/var/lib/mailman/mail/mailman request '.$name.'"',});
                Service::aliases::define({'source' => $name.'-subscribe', 'destination' => '"|/var/lib/mailman/mail/mailman subscribe '.$name.'"',});
                Service::aliases::define({'source' => $name.'-unsubscribe', 'destination' => '"|/var/lib/mailman/mail/mailman unsubscribe '.$name.'"',});

		`newaliases`;

		service "postfix" => "reload";
	}

};


sub exist {

	my $name = $_[0];

	my @list = `list_lists`;
	shift @list;

	foreach(@list){

		#we serach for the name in a case insensitive way
		if($_ =~ /$name/i){return 1;}
	}

	return 0;
}


1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::mailman/;
  
 task yourtask => sub {
    Service::mailman::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
