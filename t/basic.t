package main;

use strict;
use warnings;

use File::Spec;
use Test::More 0.88;	# For done_testing();

my $my_user = eval { getlogin || getpwuid ($<) };

my $reactos = $^O eq 'MSWin32'
    && defined $ENV{OS} && lc $ENV{OS} eq 'reactos';

require_ok 'Win32::Process::Info'
    or BAIL_OUT;

eval {
    Win32::Process::Info->import();
    1;
} or BAIL_OUT 'Win32::Process::Info->import() failed';

# Pseudo-import symbol.
our $MY_PID;
{
    no warnings qw{ once };
    *MY_PID = *Win32::Process::Info::MY_PID;
}
# diag "\$\$ = $$; \$MY_PID = $MY_PID";

is Win32::Process::Info::Version(), $Win32::Process::Info::VERSION,
    'Get our version';

foreach my $variant ( qw{ NT WMI PT } ) {

    SKIP: {

	my $tests = 10;

	my $skip = Win32::Process::Info->variant_support_status( $variant );
	note "\nTesting variant $variant";
	$skip
	    and skip $skip, $tests;

	my $pi = Win32::Process::Info->new (undef, $variant);
	ok $pi, "Instantiate variant $variant."
	    or skip "Failed to instantiate $variant", --$tests;

	ok eval { $pi->Set( elapsed_in_seconds => 1 ) },
	    'Ask for elapssed time in seconds.';


	my @pids = $pi->ListPids();
	ok scalar @pids, 'Ability to list processes.';

	my @mypid = grep { $MY_PID eq $_ } @pids;
	ok scalar @mypid, 'Our own PID should be in the list.';


	my @pinf = $pi->GetProcInfo();
	ok scalar @pinf, 'Ability to get process info.';

	my ( $me ) = $pi->GetProcInfo( $MY_PID );
	ok $me, 'Ability to get our own info.';

	like $me->{Name}, qr{ perl }smxi,
	    'Our own process should be running Perl.';


	SKIP: {

	    defined $my_user
		or skip "Can not determine username under $^O", 1;

	    TODO: {
		local $TODO;
		$reactos
		    and $TODO = 'Process ownership broken under ReactOS';

		my ( $domain, $user ) = split qr{ \\ }smx, $me->{Owner};
		is $user, $my_user,
		    'Our own process should be under our username';
	    }
	}

	SKIP: {

	    my $skip_sub = 2;

	    my $dad;
	    eval {
		$dad = getppid;
		$^O eq 'cygwin'
		    and $dad = Cygwin::pid_to_winpid( $dad );
		1;
	    } or skip 'getppid not implemented or broken', $skip_sub;

	    $variant eq 'NT'
		and skip 'Subprocesses not supported by NT variant',
		    $skip_sub;

	    my %subs = $pi->Subprocesses( $dad );
	    ok $subs{$MY_PID},
		"Call Subprocesses() and see if $MY_PID is a subprocess of $dad";

	    my ( $pop ) = $pi->SubProcInfo( $dad );
	    my @subs = @{ $pop->{subProcesses} };
	    my $bingo;
	    while ( @subs ) {
		my $proc = shift @subs;
		if ( $proc->{ProcessId} eq $MY_PID ) {
		    $bingo++;
		    last;
		} else {
		    push @subs, @{ $proc->{subProcesses} };
		}
	    }
	    ok $subs{$MY_PID},
		"Call SubProcInfo() and see if $MY_PID is a subprocess of $dad";

	}

    }

}

done_testing;

1;
