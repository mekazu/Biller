package Biller::Controller::Field;
use Mojo::Base 'Biller::Controller::Base';

use Data::Dump qw(dump);
use Carp qw(confess);

sub get {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $field = $c->param('field');
        my $query = "select * from field f where key = ?";
        my $row = $dbh->selectrow_hashref($query, {}, $field);
        die "No such field: $field" unless $row;
        return $row;
    });
}

sub get_all {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $field = $c->param('field');
        my $query = "select * from field f";
        my $rows = $dbh->selectall_arrayref($query, { Slice => {} });
        return $rows;
    });
}

sub post {
    shift->handle(sub {
        my ($c, $dbh) = @_;
        my $key = $c->param('field');
        my $label = $c->param('label') or die "Requires label";
        my $kind = $c->param('kind') or die "Requires kind";
        my $statement = 'insert into field (key, label, kind) values (?, ?, ?) returning id';
        my $id = $dbh->selectrow_array($statement, {}, $key, $label, $kind);
        return $id;
    });
}

1;
