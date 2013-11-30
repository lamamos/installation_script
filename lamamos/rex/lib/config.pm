use Storable;
use Data::Dumper;

sub ReadCfg{

    my $file = $_[0];

    our $err;

    {   # Put config data into a separate namespace
        package CFG;

        # Process the contents of the config file
        my $rc = do($file);

        # Check for errors
        if ($@) {
            $::err = "ERROR: Failure compiling '$file' - $@";
        } elsif (! defined($rc)) {
            $::err = "ERROR: Failure reading '$file' - $!";
        } elsif (! $rc) {
            $::err = "ERROR: Failure processing '$file'";
        }
    }

    return ($err);
}

sub writeCfg{

	#my %config = $_[0];
	#my $ref = $CFG::config;

=pod
	my %config = (

		'ddName'		=> '/dev/sda5',
		'ddFormated'		=> '0',
		'OCFS2Init'		=> '0',
		'drbdSharedSecret'	=> 'pqskozideufhjkdlsfkjdsclfhjbsdknlfihuksbjfy',
		'firstServHostName'	=> 'serveur1',
		'firstServIP'		=> '192.168.56.200',
	        'SeconServHostName'     => 'serveur2',
		'SeconServIP'		=> '192.168.56.201',
	);
=cut	

 #       print $CFG::config{'ddName'}."\n\n";

	my $config = $CFG::config;

	print $CFG::config{'ddName'}."\n\n";


#	my $ref = $CFG::config;
#	my %config = ();
#	%config = %$ref;

#	print Dumper(\$CFG::config);


#        my $ref = $CFG::config;
#	my %config = %$ref;

	print $ref->{ddname};

	open (FILE, '>test');
	print FILE "%config = (\n\n";

	for (keys %{$CFG::config}){

		print $_."\n";
	#	print FILE "\t\'".$_."\'\t\t=> \'".$CFG::config{$_}."\',\n"
	}

	print FILE ");\n";


}

sub getHostName {

	open FILE, "/etc/hostname" or die $!;
	while (my $line = <FILE>){

        	return $line;
	}
}

1;
