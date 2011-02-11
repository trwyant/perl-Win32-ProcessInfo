package main;

use strict;
use warnings;

use File::Spec;

BEGIN {
    eval {
	require Test::More;
	Test::More->VERSION(0.40);
	Test::More->import();
    };
    if ($@) {
	print "1..0 # skip Test::More required to criticize code.\n";
	exit;
    }
    eval {
	require Test::Perl::Critic;
	Test::Perl::Critic->import(
	    -profile => File::Spec->catfile(qw{xt author perlcriticrc})
	);
    };
    if ($@) {
	print "1..0 # skip Test::Perl::Critic required to criticize code.\n";
	exit;
    }
}

# Can't do the following until NT.pm and WMI.pm are brought into compliance
# all_critic_ok('lib');
plan (tests => 3);
critic_ok(File::Spec->catfile(qw{lib Win32 Process Info.pm}));
critic_ok(File::Spec->catfile(qw{lib Win32 Process Info NT.pm}));
critic_ok(File::Spec->catfile(qw{lib Win32 Process Info PT.pm}));

1;
