use 5.006;

use strict;
use warnings;

use Config;
use ExtUtils::MakeMaker;

## my $vers = $] >= 5.008 ? '-5.8' : '';
my $vers = '';

(my $mmv = ExtUtils::MakeMaker->VERSION) =~ s/_//g;
WriteMakefile (
	NAME => 'Win32::Process::Info',
	VERSION_FROM => 'lib/Win32/Process/Info.pm',
	PREREQ_PM => {
			},
#	'linkext' => {LINKTYPE => ''},
	PL_FILES => {},	# Prevent old MakeMaker from running Build.PL
	'dist' => {COMPRESS => 'gzip', SUFFIX => 'gz'},
	$] >= 5.005 ? (
		AUTHOR => 'Tom Wyant (wyant at cpan dot org)',
		ABSTRACT => 'Get information on arbitrary processes in Windows NT',
		BINARY_LOCATION => "$Config{archname}$vers/Win32-Process-Info.tar.gz",
		) : (),
		($mmv >= 6.31 ?
		    (LICENSE => 'perl') : ())
	);

