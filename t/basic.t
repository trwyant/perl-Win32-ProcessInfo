package main;

use strict;
use warnings;

use File::Spec;
use Test;

my ($proc, $wmi);
my $my_user = getlogin || getpwuid ($<);
my $nt_skip;
BEGIN {
    $nt_skip = 'NT-Family OS required.';
    eval {
	require Win32;

	if ($^O eq 'MSWin32' && lc $ENV{OS} eq 'reactos') {
	    $wmi = "WMI does not work under ReactOS";
	} elsif (eval {require Win32::OLE; 1}) {
	    my $old_warn = Win32::OLE->Option ('Warn');	# Sure wish I could localize this baby.
	    Win32::OLE->Option (Warn => 0);
	    $wmi = Win32::OLE->GetObject ('winmgmts:{impersonationLevel=impersonate,(Debug)}!//./root/cimv2');
	    $proc = $wmi->Get ("Win32_Process='$$'") if $wmi;
	    $wmi = undef unless $wmi && $proc;
	    Win32::OLE->Option (Warn => $old_warn);
	}

#	Figure out whether we support the NT variant.

	$nt_skip = Win32::IsWinNT () ? eval {require Win32::API} ? 0 :
	    "Skip Win32::API not installed." :
	    "Skip Windows NT-family OS required.";
	my @path = split ';', $ENV{Path};
	unless ($nt_skip) {
	DLL_LOOP:
	    foreach my $dll (qw{PSAPI.DLL ADVAPI32.DLL KERNEL32.DLL}) {
		foreach my $loc (@path) {
		    next DLL_LOOP if -e File::Spec->catfile ($loc, $dll);
		}
		$nt_skip = "Skip $dll not found.";
		last;
	    }
	}
    };
###    $@ and do {chomp $@; print "# Information - Windows check exception: $@\n"};
}

# OK, we've checked all the "external" causes of failure for the NT
# variant that I can think of.

local $ENV{PERL_WIN32_PROCESS_INFO_WMI_DEBUG_PRIV} = '';
local $ENV{PERL_WIN32_PROCESS_INFO_WMI_PARIAH} = '';

print "# Information - WMI object = ", defined $wmi ? "'$wmi'\n" : "undefined\n";
print "# Information - WMI process object = ", defined $proc ? "'$proc'\n" : "undefined\n";
## print "# Win32::OLE->LastError = @{[Win32::OLE->LastError () || 'none']}\n";

my %skip = (
    NT	=> $nt_skip,
    WMI	=> ($wmi ? 0 : "Skip WMI required."),
    );

eval {require Proc::ProcessTable};
$skip{PT} = $@ ? "Unable to load Proc::ProcessTable" : 0;

$ENV{PERL_WIN32_PROCESS_INFO_VARIANT} and do {
    my %var = map {($_, 1)} split ',', uc $ENV{PERL_WIN32_PROCESS_INFO_VARIANT};
    foreach (keys %skip) {
	$skip{$_} ||= 'Skip not in $ENV{PERL_WIN32_PROCESS_INFO_VARIANT}'
	    unless $var{$_};
	}
    };

foreach (@ARGV) {$skip{$_} = "Skip user request" unless $skip{$_}}

my $test_num = 1;

################### We start with some black magic to print on failure.

# (It may become useful if the test is moved to ./t subdirectory.)

# Note - number of tests is 2 (load and version) + 7 * number of variants

my $loaded;
BEGIN {
    $| = 1;	## no critic (RequireLocalizedPunctuationVars)
    plan (tests => 23);
    print "# Test 1 - Loading the library.\n"
}
END {print "not ok 1\n" unless $loaded;}
use Win32::Process::Info;
$loaded = 1;
ok ($loaded);

######################### End of black magic.

$test_num++;
print "# Test $test_num - See if we can get our version.\n";
ok (Win32::Process::Info::Version () eq $Win32::Process::Info::VERSION);


foreach my $variant (qw{NT WMI PT}) {

    my $skip = $skip{$variant};
    print "# Testing variant $variant. Skip = '$skip'\n";

    $test_num++;
    print "# Test $test_num - Instantiating the $variant variant.\n";
    my $pi;
    $skip or $pi = Win32::Process::Info->new (undef, $variant);
    skip ($skip, $pi);
    ($pi || $skip)
	or $skip = "Skip Can't instatiate $variant variant";


    $test_num++;
    print "# Test $test_num - Ability to list processes.\n";
    my @pids;
    $skip or @pids = $pi->ListPids ();
    skip ($skip, scalar @pids);


    $test_num++;
    print "# Test $test_num - Our own PID should be in the list.\n";
    my @mypid = grep {$$ eq $_} @pids;
    skip ($skip, scalar @mypid);


    $test_num++;
    print "# Test $test_num - Ability to get process info.\n";
    my @pinf;
    $skip or @pinf = $pi->GetProcInfo ();
    skip ($skip, scalar @pinf);


    $test_num++;
    print "# Test $test_num - Ability to get our own info.\n";
    my $me;
    $skip or ($me) = $pi->GetProcInfo ($$);
    skip ($skip, $me);


    $test_num++;
    print "# Test $test_num - Our own process should be running Perl.\n";
    skip ($skip, $me->{Name}, qr{(?i:perl)});


    $test_num++;
    print "# Test $test_num - Our own process should be under our username.\n";
    my ($domain, $user) = $skip || !$me->{Owner} ? ('', '') :
	split '\\\\', $me->{Owner};
    skip ($skip || (defined $my_user ? undef :
	    "Can not determine username under $^O"),
	defined $my_user && $user eq $my_user);
}

1;
