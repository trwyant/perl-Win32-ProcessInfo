use strict;
use warnings;

use Module::Build;
use Config;
use FileHandle;

our $VERSION = '0.002';

my $bldr = Module::Build->new (
	dist_author => 'Tom Wyant (wyant at cpan dot org)',
	dist_abstract => 'Get information on arbitrary processes in Windows NT',
	module_name => 'Win32::Process::Info',
	requires => {
	},
#	dist_version_from => 'lib/Win32/Process/Info.pm',
#	dynamic_config => 1,
	license => 'perl',
	);

$bldr->create_build_script ();
