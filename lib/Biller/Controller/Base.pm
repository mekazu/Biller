package Biller::Controller::Base;
use Mojo::Base 'Mojolicious::Controller';
use DBI;

my $_dbh;
sub dbh {
    return $_dbh ||= DBI->connect("dbi:Pg:dbname=biller", '', '', {RaiseError => 1, PrintError => 0, AutoCommit => 0});
}

sub handle {
    my ($self, $sub) = @_;
    my $dbh = dbh();
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
        $_dbh = undef;
        warn $error;
        $status = 500;
        $result = { error => $error };
    };
    $dbh->disconnect;
    $_dbh = undef;
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

