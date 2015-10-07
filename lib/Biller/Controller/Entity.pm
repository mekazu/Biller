package Biller::Controller::Entity;
use Mojo::Base 'Biller::Controller::Base';

use Data::Dump qw(dump);

sub get {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $entity = $c->param('entity');
        my $value_kind_query = 'select enumlabel from pg_enum e inner join pg_type k on k.oid = e.enumtypid where k.typname = ?';
        my $value_kinds = $dbh->selectall_arrayref($value_kind_query, {}, 'field_value_kind');
        my @kinds = map { $_->[0] } @$value_kinds;
        my $query = "select * from current_attribute_with_fields a";
        $query .= join "", map { " left join ${_}_attribute $_ on $_.attribute = a.id" } @kinds;
        $query .= " where entity = ?";
        my $rows = $dbh->selectall_arrayref($query, { Slice => {} }, $entity);

        # Unpack the results, filtering out the unneeded values.
        my $filtered_rows = [];
        foreach my $row (@$rows) {
            my $filter_row;
            foreach my $key (keys %$row) {
                if ($key =~ m/_value$/) {
                    if ($key eq "$row->{kind}_value") {
                        my $value = $row->{$key};
                        $row->{value} = $value;
                        $filter_row = 1 unless defined $value;
                    }
                    delete $row->{$key};
                } elsif ($key =~ m/^id|attribute|field$/) {
                    delete $row->{$key};
                }
            }
            push @$filtered_rows, $row unless $filter_row;
        }
        return $filtered_rows;
    });
}

sub get_children {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $entity = $c->param('entity');
        my $query = 'select * from current_attribute_with_fields a';
        $query .= ' inner join int_attribute int on int.attribute = a.id';
        $query .= ' where a.key = ? and int.int_value = ?';
        my $rows = $dbh->selectall_arrayref($query, { Slice => {} }, 'parent', $entity);
        my $children = [ map { $_->{entity} } @$rows ];
        return $children;
    })
}

sub get_related {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $entity = $c->param('entity');

        # Most of this banal complexity is due to the absurdly restrictive
        # model provided by the database schema. It would probably make more
        # sense just to create dedicated tables for storing relationships
        # between entities but this at least demonstrates that it can be done.
        my $query = <<EOSQL;
select ev.text_value as grouping, d.int_value as related

-- Link attribute(s) related to our entity.
from current_int_attribute_with_fields a

-- Find the parent attribute(s) of the same Link entity or entities.
-- The parent attributes point to the Grouping entity.
inner join current_int_attribute_with_fields b
on a.entity = b.entity
and b.key = 'parent'

-- Find all other entities linked to the Grouping entity with the same parent attribute.
inner join current_int_attribute_with_fields c
on b.int_value = c.int_value
and c.key = 'parent'
-- and c.entity != a.entity -- commented out to include the current entity.

-- For each of these Link entities find related entities via their 'related' attribute.
-- d.int_value will be the related entity id.
inner join current_int_attribute_with_fields d
on c.entity = d.entity
and d.key = 'related'

-- Finally, grab the 'type' attribute of the Grouping entity.
inner join current_attribute_with_fields e
on e.entity = b.int_value
and e.key = 'type'
inner join text_attribute ev
on e.id = ev.attribute

-- Find all 'link' entities related to our entity.
where a.key = 'related'
and a.int_value = ?
EOSQL
        my $rows = $dbh->selectall_arrayref($query, { Slice => {} }, $entity);
        my $related;
        push @{$related->{ $_->{grouping}}}, $_->{related} foreach (@$rows);
        return $related;
    });
}

sub post {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $entity_kind = $c->param('kind');
        my $insert_entity = 'insert into entity values (default) returning id';
        my ($entity_id) = $dbh->selectrow_array($insert_entity);
        my $params = $c->req->params->to_hash;
        while (my ($key, $value) = (each %$params)) {
            _insert_attribute($dbh, $entity_id, $key, $value);
        }
        return { entity => $entity_id };
    });
}

sub patch {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $entity_id = $c->param('entity');
        my $params = $c->req->params->to_hash;
        my $inserted_attribute_ids = [];
        while (my ($key, $value) = (each %$params)) {
            push @$inserted_attribute_ids, _insert_attribute($dbh, $entity_id, $key, $value);
        }
        return $inserted_attribute_ids;
    });
}

sub _insert_attribute {
    my ($dbh, $entity, $key, $value) = @_;
    my $select_field = 'select id, kind from field where key = ?';
    my ($field_id, $field_kind) = $dbh->selectrow_array($select_field, {}, $key);
    if (defined $field_id) {
        my $insert_attribute_statement = "insert into attribute
            (entity,    field) values
            (?,         ?) returning id";
        my $insert_attribute_kind_statement = "insert into ${field_kind}_attribute
            (attribute, ${field_kind}_value) values
            (?,         ?)";
        my ($attribute_id) = $dbh->selectrow_array($insert_attribute_statement, {}, $entity, $field_id);
        $value = undef if $value eq q{};
        $dbh->do($insert_attribute_kind_statement, {}, $attribute_id, $value);
        return $attribute_id;
    }
    return;
}

1;
