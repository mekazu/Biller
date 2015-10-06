use Test::Mojo;
use Test::More;
use FindBin;

require "bin/biller.pl";

my $t = Test::Mojo->new;

$t->get_ok('/entity/1');

done_testing;
