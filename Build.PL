use 5.006;

use strict;
use warnings;

use lib qw{inc};
use Module::Build;
use My::Module::Build;
use Config;

(my $mbv = Module::Build->VERSION) =~ s/_//g;

my %args = (
    dist_author => 'Tom Wyant (wyant at cpan dot org)',
    dist_abstract => 'Get information on arbitrary processes in Windows NT',
    module_name => 'Win32::Process::Info',
    requires => {},
    license => 'perl',
);

$mbv >= 0.28 and $args{meta_merge} = {
    no_index => {
	directory => [qw{inc t}],
    },
    resources => {
	bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Win32-Process-Info',
    },
};

$mbv >= 0.34
    and $args{auto_configure_requires} = 0;	# Don't require Module::Build

my $bldr = My::Module::Build->new(%args);

$bldr->create_build_script ();
