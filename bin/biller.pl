#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
use Data::Dump qw(dump);

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get '/entity/:entity' => sub {
    handle(shift, sub {
        my ($c, $dbh) = @_;
        my $entity = $c->param('entity');
        my $value_types = $dbh->selectall_arrayref('
            select enumlabel from pg_enum e
            inner join pg_type k
            on k.oid = e.enumtypid
            where k.typname = ?
            ', {}, 'field_value_kind');
        my @types = map { $_->[0] } @$value_types;
        my $query = "select * from current_attribute_with_fields a";
        $query .= join "", map { " left join ${_}_attribute $_ on $_.attribute = a.id" } @types;
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
};

post '/entity' => sub {
    handle (shift, sub {
        my ($c, $dbh) = @_;
        my $entity_kind = $c->param('kind');
        my $insert_entity = 'insert into entity (kind) values (?) returning id';
        my ($entity_id) = $dbh->selectrow_array($insert_entity, {}, $entity_kind);
        my $params = $c->req->params->to_hash;
        warn "Inserting attributes: @{[dump $params]}";
        while (my ($key, $value) = (each %$params)) {
            insert_attribute($dbh, $entity_id, $key, $value);
        }
        return { entity => $entity_id };
    });
};

sub insert_attribute {
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
        warn "Inserted attribute: $attribute_id";
        return $attribute_id;
    }
    return;
}

patch '/entity/:entity' => sub {
    handle(shift, sub {
        my ($c, $dbh) = @_;
        my $entity_id = $c->param('entity');
        my $params = $c->req->params->to_hash;
        my $inserted_attribute_ids = [];
        while (my ($key, $value) = (each %$params)) {
            push @$inserted_attribute_ids, insert_attribute($dbh, $entity_id, $key, $value);
        }
        return $inserted_attribute_ids;
    });
};

my $_dbh;
sub dbh {
    return $_dbh ||= DBI->connect("dbi:Pg:dbname=biller", '', '', {RaiseError => 1, PrintError => 0, AutoCommit => 0});
}

sub handle {
    my ($c, $sub) = @_;
    my $dbh = dbh();
    my $result;
    my $status = 200;
    eval {
        $result = $sub->($c, $dbh);
        $dbh->commit;
        1;
    } or do {
        my $error = $@;
        $dbh->rollback;
        $dbh->disconnect;
        $_dbh = undef;
        warn $error;
        $status = 500;
        $result = { error => $error };
    };
    $dbh->disconnect;
    $_dbh = undef;
    my %response = (status => $status);
    if ($result) {
        $response{json} = $result;
    } else {
        $response{text} = q{};
    }
    $c->render(%response);
    return;
}

app->start;
