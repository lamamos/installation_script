package Service::apache::vhost;

use Rex -base;



desc "create a new vhost";
task define => sub{

	my $variables = $_[0];

	if(!defined $variables->{server_name}){die "serveur_name must be defined.";}
	$variables->{ssl} //= 0;
	$variables->{ssl_cert_dir} //= "/etc/ssl/certs";
	$variables->{file_name} //= $variables->{server_name};
	$variables->{manage_folder} //= 0;
	if($variables->{manage_folder}){

		if(!defined $variables->{docroot_owner}){die "When the managing the folder docroot_owner  must be defined.";}
		if(!defined $variables->{docroot_group}){die "When the managing the folder docroot_group must be defined.";}
		if(!defined $variables->{docroot_mode}){die "When the managing the folder docroot_mode must be defined.";}
	}





	if($variables->{manage_folder}){
		mkdir $variables->{docroot},
			owner	=> $variables->{docroot_owner},
			group 	=> $variables->{docroot_group},
			mode	=> $variables->{docroot_mode},
	}

        file "/etc/apache2/sites-enabled/".$variables->{file_name}.".conf",
                content         => template("templates/vhost.conf.tpl", variables => $variables),
                owner           => "root",
                group           => "root",
                mode            => "644",
                on_change       => sub{ service "apache2" => "reload"; };
};






1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::apache/;
  
 task yourtask => sub {
    Service::apache::example();
 };

=head1 ARGUMENTS

string server_name
number port
string server_admin
string docroot
bool ssl
string ssl_cert_dir
string file_name
bool manage_folder
string docroot_owner
string docroot_group
string docroot_mode

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
