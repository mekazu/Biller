package Biller::Controller::Accounting;
use Mojo::Base 'Biller::Controller::Base';

use Data::Dump qw(dump);
use Carp qw(confess);

sub get_transactions {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $entity = $c->param('entity');
        my $query = <<"EOSQL";
select sum(amount.int_value) as credits
from current_int_attribute_with_fields parent
inner join current_int_attribute_with_fields amount
on parent.entity = amount.entity
and amount.key = 'amount'
inner join current_text_attribute_with_fields type
on parent.entity = type.entity
and type.key = 'type'
and type.text_value = 'transaction'
where parent.key = 'parent'
and parent.int_value = ?;
EOSQL
        my $credits = $dbh->selectrow_array($query, {}, $entity);
        return $credits;
    });
}

1;
