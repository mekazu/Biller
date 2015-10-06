use Test::Mojo;
use Test::More;

my $t = Test::Mojo->new('Biller');

$t->get_ok('/entity/1');

done_testing;
