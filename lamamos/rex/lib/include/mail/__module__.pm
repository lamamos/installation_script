package include::mail;

use Rex -base;
require Service::postfix;
require Service::dovecot;
require Service::mailman;
require Service::mailman::maillinglist;

task define => sub {

        Service::postfix::define({

                'manage_service' => 0,
                'sasl_enabled' => 1,
                'spamassassin_enabled' => 1,
        });



        Service::dovecot::define({

                'plugins'                       => ['sieve', 'managesieved'],
                'protocols'                     => 'imap sieve',
                'listen'                        => '*',
                'verbose_proctitle'             => 'yes',
                'mail_location'                 => 'maildir:~/Maildir',
                'auth_listener_postfix'         => 1,
                'ssl'                           => 'yes',
                'ssl_cert'                      => '/ssl/certificat.crt',
                'ssl_key'                       => '/ssl/certificat.key',
                'postmaster_address'            => 'root@martobre.fr',
                'hostname'                      => 'serveur.martobre.fr',
                'lda_mail_plugins'              => '$mail_plugins sieve',
                'mail_max_userip_connections'   => '512',
        });

	Service::mailman::define({

		'mailDomain'	=> 'martobre.fr',
		'vhostAddress'	=> 'lists.martobre.fr',
	});

	Service::mailman::maillinglist::define({

		'name'		=> 'c4',
		'adminAddress'	=> 'karlito@martobre.fr',
		'password'	=> 'yzZxX0_p',
	});
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/include::mail/;
  
 task yourtask => sub {
    include::mail::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
