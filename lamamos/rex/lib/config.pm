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

		#the chomp remove the \n at the end of the line
		chomp($line);
        	return $line;
	}
}

1;
