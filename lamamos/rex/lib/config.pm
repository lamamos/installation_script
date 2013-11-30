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

	my $file = $_[0];

	open (FILE, '>'.$file);
	print FILE "%config = (\n\n";

	for (keys %CFG::config){

		#print $_."\n";
		print FILE "\t\'".$_."\'\t\t=> \'".$CFG::config{$_}."\',\n"
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
