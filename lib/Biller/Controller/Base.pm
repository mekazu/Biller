package Biller::Controller::Base;
use Mojo::Base 'Mojolicious::Controller';
use DBI;

sub dbh {
    my ($class, $dbh_to_set) = @_;
    our ($dbh, $dbh_callback);
    if (@_ > 1) {
        $dbh = $dbh_to_set;
        return unless defined $dbh;
    }
    my $attr = { RaiseError => 1, PrintError => 0, AutoCommit => 0 };
    $dbh_callback ||= sub { DBI->connect("dbi:Pg:dbname=biller", '', '', $attr ) };
    return $dbh ||= $dbh_callback->();
}

sub handle {
    my ($self, $sub) = @_;
    my $dbh = $self->dbh;
    my $result;
    my $status = 200;
    eval {
        $result = $sub->($self, $dbh);
        $dbh->commit;
        1;
    } or do {
        my $error = $@;
        $dbh->rollback;
        $dbh->disconnect;
        $self->dbh(undef);
        warn $error;
        $status = 500;
        $result = { error => $error };
    };
    $dbh->disconnect;
    $self->dbh(undef);
    my %response = (status => $status);
    if (defined $result) {
        $response{json} = $result;
    } else {
        $response{text} = q{};
    }
    $self->render(%response);
    return;
}

1;

