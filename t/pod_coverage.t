use strict;
use warnings;

my $ok;
BEGIN {
    eval "use Test::More";
    $ok = !$@;
}

if ($ok) {
    eval "use Test::Pod::Coverage";
    plan skip_all => "Test::Pod::Coverage required to test POD coverage." if $@;
##    if ($^O eq 'MSWin32') {
##	all_pod_coverage_ok (
##	    {coverage_class => 'Pod::Coverage::CountParents'});
##    } else {
	plan tests => 1;
	pod_coverage_ok ('Win32::Process::Info');
##    }
} else {
    print <<eod;
1..1
ok 1 # skip Test::More required for testing POD coverage.
eod
}
