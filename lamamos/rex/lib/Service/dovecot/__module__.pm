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

package Service::dovecot;

use Rex -base;

task define => sub {

	my $variables = $_[0];

	$variables->{"pluggins"} //= [];
	$variables->{"protocols"} //= '';
	$variables->{"listen"} //= '*';
	$variables->{"verbose_proctitle"} //= 'yes';
	$variables->{"mail_location"} //= 'maildir:~/Maildir';
	$variables->{"auth_listener_postfix"} //= 1;
	$variables->{"ssl"} //= 'no';
	$variables->{"postmaster_address"} //= 'root@martobre.fr';
	if(!defined $variables->{"hostname"}){die "hostname must be defined";}
	$variables->{lda_mail_plugins} //= '$mails_plugins';
	$variables->{auth_master_separator} //= '*';
	$variables->{auth_mechanisms} //= 'plain';
	$variables->{auth_include} //= ['system'];
	$variables->{mail_max_userip_connections} //= 100;
	$variables->{sieve} //= '~/.dovecot.sieve';
	$variables->{sieve_dir} //= '~/sieve';



	install ["dovecot-common", "dovecot-imapd"];
	foreach(@{$variables->{plugins}}){install "dovecot-".$_;}

        file "/etc/dovecot/dovecot.conf",
                content => template("templates/dovecot.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/10-auth.conf",
                content => template("templates/conf.d/10-auth.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/10-logging.conf",
                content => template("templates/conf.d/10-logging.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/10-mail.conf",
                content => template("templates/conf.d/10-mail.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/10-master.conf",
                content => template("templates/conf.d/10-master.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/10-ssl.conf",
                content => template("templates/conf.d/10-ssl.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/15-lda.conf",
                content => template("templates/conf.d/15-lda.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/15-mailboxes.conf",
                content => template("templates/conf.d/15-mailboxes.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };

        file "/etc/dovecot/conf.d/20-imap.conf",
                content => template("templates/conf.d/20-imap.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };


        file "/etc/dovecot/conf.d/90-sieve.conf",
                content => template("templates/conf.d/90-sieve.conf.tpl", variables => $variables),
                owner => "root",
                group => "root",
                mode => "644",
                on_change => sub{ service "dovecot" => "reload"; };



	service dovecot => ensure => "started";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::dovecot/;
  
 task yourtask => sub {
    Service::dovecot::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
