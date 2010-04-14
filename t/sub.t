package main;

use strict;
use warnings;

use Test;

my $dad;
eval { $dad = getppid(); 1 } or do {
    print "1..0 # Skip getppid() not implemented, or failed\n";
    exit;
};

eval { require Win32::Process::Info; 1 } or do {
    print "1..0 # Skip unable to load Win32::Process::Info\n";
    exit;
};
Win32::Process::Info->import();

my $pi = Win32::Process::Info->new(undef, 'NT,PT') or do {
    print "1..0 # Skip unable to instantiate Win32::Process::Info\n";
    exit;
};

plan (tests => 2);

print <<eod;
#
#	My process ID = $$
#	Parent process id = $dad
eod

{
    print <<eod;
#
# Test 1: Call Subprocesses() and see if $$ is a subprocess of $dad
eod
    my %subs = $pi->Subprocesses($dad);
    ok ($subs{$$});
}

{
    print <<eod;
#
# Test 2: Call SubProcInfo() and see if $$ is a subprocess of $dad
eod
    my ($pop) = $pi->SubProcInfo($dad);
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
    ok ($bingo);
}

1;
