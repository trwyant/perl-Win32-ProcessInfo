package main;

use strict;
use warnings;

use Test::More 0.88;

use Win32::Process::Info;

my $dad;
eval {
    $dad = getppid();
    1;
} or do {
    plan skip_all => 'getppid() not implemented, or failed';
    exit;
};

my $pi = eval {
    Win32::Process::Info->new(undef, 'WMI,PT')
} or do {
    plan skip_all => 'unable to instantiate Win32::Process::Info';
    exit;
};

my $my_pid = $pi->My_Pid();
my $variant = $pi->Get( 'variant' );
my $prefix = "Variant $variant:";

$^O eq 'cygwin'
    and $variant ne 'PT'
    and $variant = Cygwin::pid_to_winpid( $dad );

{
    my %subs = $pi->Subprocesses($dad);
    ok $subs{$my_pid},
	"$prefix Call Subprocesses() and see if $my_pid is a subprocess of $dad";
}

{
    my ($pop) = $pi->SubProcInfo($dad);
    my @subs = @{$pop->{subProcesses}};
    my $bingo;
    while (@subs) {
	my $proc = shift @subs;
	$proc->{ProcessId} == $my_pid and do {
	    $bingo++;
	    last;
	};
	push @subs, @{$proc->{subProcesses}};
    }
    ok $bingo,
	"$prefix Call SubProcInfo() and see if $my_pid is a subprocess of $dad";
}

done_testing;

1;

__END__

# ex: set textwidth=72 :
