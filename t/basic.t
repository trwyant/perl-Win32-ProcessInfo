package main;

use strict;
use warnings;

use File::Spec;
use Test;

my $my_user = eval { getlogin || getpwuid ($<) };
my $reactos = $^O eq 'MSWin32' && lc $ENV{OS} eq 'reactos';

# Note - number of tests is 2 (load and version) + 10 * number of variants
my @todo;
$reactos and push @todo, 10;
plan( tests => 32, todo => \@todo );

my $test_num = 1;

print '# Test ', $test_num++, " - require Win32::Process::Info\n";
my $loaded = eval {
    require Win32::Process::Info;
    Win32::Process::Info->import();
    1;
};
ok( $loaded );
$loaded or do {
    print "Bail out!  Unable to require Win32::Process::Info\n";
    exit 255;
};

print '# Test ', $test_num++, " - Get our version\n";
ok (Win32::Process::Info::Version () eq $Win32::Process::Info::VERSION);

foreach my $variant (qw{NT WMI PT}) {

    my $skip = Win32::Process::Info->variant_support_status( $variant );
    print "# Testing variant $variant. Skip = '$skip'\n";

    print '# Test ', $test_num++, " - Instantiating the $variant variant\n";
    my $pi;
    $skip or $pi = Win32::Process::Info->new (undef, $variant);
    skip ($skip, $pi);
    ($pi || $skip)
	or $skip = "Skip Can't instatiate $variant variant";


    print '# Test ', $test_num++, " - Ask for elapsed time in seconds.\n";
    skip( $skip, $skip || eval { $pi->Set( elapsed_in_seconds => 1 ) } );


    print '# Test ', $test_num++, " - Ability to list processes.\n";
    my @pids;
    $skip or @pids = $pi->ListPids ();
    skip ($skip, scalar @pids);


    print '# Test ', $test_num++, " - Our own PID should be in the list.\n";
    my @mypid = grep {$$ eq $_} @pids;
    skip ($skip, scalar @mypid);


    print '# Test ', $test_num++, " - Ability to get process info.\n";
    my @pinf;
    $skip or @pinf = $pi->GetProcInfo ();
    skip ($skip, scalar @pinf);


    print '# Test ', $test_num++, " - Ability to get our own info.\n";
    my $me;
    $skip or ($me) = $pi->GetProcInfo ($$);
    skip ($skip, $me);


    print '# Test ', $test_num++, " - Our own process should be running Perl.\n";
    skip ($skip, $me->{Name}, qr{(?i:perl)});


    print '# Test ', $test_num++, " - Our own process should be under our username.\n";
    my ($domain, $user) = $skip || !$me->{Owner} ? ('', '') :
	split '\\\\', $me->{Owner};
    skip ($skip || (defined $my_user ? undef :
	    "Can not determine username under $^O"),
	defined $my_user && $user eq $my_user);


    {
	my $dad = '<unsupported>';
	my $skip_sub = (
	    eval { $dad = getppid(); 1 } ? 0 :
	    'getppid not implemented or broken'
	) || (
	    'NT' eq $variant ? 'Subprocesses not supported by NT variant' : 0
	);
	$skip and $skip_sub = $skip;

	print '# Test ', $test_num++, " - Call Subprocesses ",
	    "and see if $$ is a subprocess of $dad\n";
	my %subs = $skip_sub ? () : $pi->Subprocesses( $dad );
	skip( $skip_sub, $subs{$$} );

	print '# Test ', $test_num++, " - Call SubProcInfo ",
	    "and see if $$ is a subprocess of $dad\n";
	my ($pop) = $skip_sub ? { subProcesses => [] } : $pi->SubProcInfo($dad);
	my @subs = @{$pop->{subProcesses}};
	my $bingo;
	while (@subs) {
	    my $proc = shift @subs;
	    $proc->{ProcessId} == $$ and do {
		$bingo++;
		last;
	    };
	    push @subs, @{$proc->{subProcesses}};
	}
	skip( $skip_sub, $bingo );

    }


}

1;
