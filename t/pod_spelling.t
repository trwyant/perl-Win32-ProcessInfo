#!/usr/local/bin/perl

use strict;
use warnings;

my $skip;
BEGIN {
    eval "use Test::Spelling";
    $@ and do {
	eval "use Test";
	plan (tests => 1);
	$skip = 'Test::Spelling not available';;
    };
}

our $VERSION = '0.001';

if ($skip) {
    skip ($skip, 1);
} else {
    add_stopwords (<DATA>);

    all_pod_files_spelling_ok ();
}
__DATA__
Aldo
Amine
API
APIs
Calpini
DLL
ExecutablePath
Faylor
GetProcInfo
GetProcInfo's
IDs
ISBN
Jenda
Jutta
Klebe
Krynicky
LibWin
MaximumWorkingSetSize
MinimumWorkingSetSize
Moulay
NT
NT's
NtQuerySystemInformation
Nemours
PIDs
PPM
PT
ParentProcessId
Prantl
ProcessId
Pulist
Ramdane
Roth
SID
Urist
Urist's
VCC
Winternl
WMI
Wyant
cc
clunks
de
dll
exe
exportable
gory
ntdll
pids
ps
psapi
pulist
retrofitted
stime
username
winpid
winppid
xs

