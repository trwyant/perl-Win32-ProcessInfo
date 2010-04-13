package main;

use strict;
use warnings;

BEGIN {
    eval {
	require Test::Spelling;
	Test::Spelling->import();
    };
    $@ and do {
	print "1..0 # skip Test::Spelling not available.\n";
	exit;
    };
}

add_stopwords (<DATA>);

all_pod_files_spelling_ok ();

1;
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
OSes
PIDs
PPM
PT
ParentProcessId
Prantl
ProcessId
Pulist
Ramdane
ReactOS
Roth
SID
SubProcInfo
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
ness
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
