use warnings;
use strict;
use feature ':5.10';

warnings->import;
strict->import;
feature->import(':5.10');
use POSIX qw(locale_h); BEGIN { setlocale(LC_MESSAGES,'en_US.UTF-8') } # avoid UTF-8 in $!
use Test::More;
use Test::Output qw( :all );
use Path::Tiny;

use constant BASEVER => path('VERSION')->lines({chomp=>1});


my $base    = path('.release/'.BASEVER.'.migrate')->slurp_utf8;


sub release {
    my ($migrate) = join "\n", @_;
    state $n = 0;
    my $testver = BASEVER . '.TEST.' . $n++;
    path(".release/$testver.migrate")->spew_utf8($base . $migrate . "\nVERSION $testver\n");
    return $testver;
}

sub not_install { install(shift, 1) }

sub install {
    my ($ver, $should_fail) = @_;
    my $status;
    my $output = output_from { $status = system "narada-install -R \Q$ver\E </dev/null" };
    if ($status != 0 xor $should_fail) {
        diag $output;
        die "system(narada-install $ver): $?\n";
    }
}

END {
    system sprintf 'narada-install -R %s >/dev/null 2>&1 && rm -rf .release/*.TEST.*', quotemeta BASEVER;
}


1;
