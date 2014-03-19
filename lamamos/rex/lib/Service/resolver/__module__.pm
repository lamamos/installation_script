package Service::resolver;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	if(!$variables->{name_servers} eq 'ARRAY'){die "the name_servers variable must be defined as an array.";}
	$variables->{domain_name} //= "";
        if(!$variables->{search_path} eq 'ARRAY'){die "the search_path variable must be defined as an array.";}


        file "/etc/resolv.conf",
		content => template("templates/resolv.conf.tpl", variables => $variables),
		owner => "root",
		group => "root",
		mode => "644";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::resolver/;
  
 task yourtask => sub {
    Service::resolver::example();
 };

=head1 ARGUMENTS

string domain_name
array string search_path
array string name_servers

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
