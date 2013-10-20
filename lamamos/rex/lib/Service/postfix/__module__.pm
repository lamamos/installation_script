package Service::postfix;

use Rex -base;
use Rex::Commands::User;
use Data::Dumper;

task define => sub {

	my $variables = $_[0];

	$variables->{manage_service} //= 1;
	$variables->{sasl_enabled} //= 0;
	$variables->{spamassassin_enabled} //= 0;

	install "postfix";

	file "/etc/postfix/main.cf",
		content	=> template("templates/main.cf.tpl", variables => $variables),
		owner	=> "root",
		group	=> "root",
		mode	=> "644",
		on_change	=> sub{ service "postfix" => "reload"; };

        file "/etc/postfix/master.cf",
                content => template("templates/master.cf.tpl", variables => $variables),
                owner   => "root",
                group   => "root",
                mode    => "644",
                on_change       => sub{ service "postfix" => "reload"; };

        file "/etc/postfix/virtual",
                source  => "files/virtual.tpl",
                owner   => "root",
                group   => "root",
                mode    => "644",
                on_change       => sub{ `/usr/sbin/postmap /etc/postfix/virtual` };


	if($variables->{sasl_enabled}){install_sasl($variables)}
	if($variables->{spamassassin_enabled}){install_spamassassin($variables);}

	if($variables->{manage_service}){

		service postfix => ensure => "started";
	}

};

sub install_spamassassin {

	my $variables = $_[0];

	install ["spamassassin", "pyzor", "razor", "spamc"];

        create_user "spamd",
                home            => '/var/lib/spamd',
                no_create_home  => 0;

        file "/etc/default/spamassassin",
                content => template("templates/spamassassin.tpl", variables => $variables),
                owner   => "root",
                group   => "root",
                mode    => "644",
                on_change       => sub{
					service "spamassassin" => "restart"; 

					`su - karlito -c 'razor-admin -create'`;
			        	`su - karlito -c 'razor-admin -register'`;
        				`su - karlito -c 'pyzor discover'`;
				};

                service spamassassin => ensure => "started";
}

sub install_sasl {

	my $variables = $_[0];

	install ["libsasl2-modules", "sasl2-bin"];

	service saslauthd => ensure => "started";

        create_user "postfix",
                home            => '/var/spool/postfix',
                no_create_home  => 1,
		system		=> 1,
                groups          => ['sasl', 'postfix'];

        file "/etc/postfix/sasl/smtpd.conf",
                content => template("templates/smtpd.conf.tpl", variables => $variables),
                owner   => "root",
                group   => "root",
                mode    => "644",
                on_change       => sub{ service "postfix" => "reload"; };

        file "/etc/default/saslauthd",
                content => template("templates/saslauthd.tpl", variables => $variables),
                owner   => "root",
                group   => "root",
                mode    => "644",
                on_change       => sub{ service "postfix" => "reload"; };
}



1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::postfix/;
  
 task yourtask => sub {
    Service::postfix::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
