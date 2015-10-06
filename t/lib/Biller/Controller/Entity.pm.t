use Test::Mojo;
use Test::More;
use Test::Differences;
use Biller::Controller::Base;

my $dbh = DBI->connect("DBI:Mock:", '', '', {RaiseError => 1, PrintError => 0, AutoCommit => 0 } );
local $Biller::Controller::Base::dbh_callback = sub { $dbh };

my $t = Test::Mojo->new('Biller');

subtest 'get' => sub {
    my $mocked_sqls = [
        {
            sql => 'select enumlabel from pg_enum e inner join pg_type k on k.oid = e.enumtypid where k.typname = ?',
            params => ['field_value_kind'],
            results => [
                [qw(kind)],
                [qw(boolean)]
            ],
        },
        {
            sql => 'select * from current_attribute_with_fields a left join boolean_attribute boolean on boolean.attribute = a.id where entity = ?',
            params => [1],
            results => [
                [qw(foo boolean_value something_value id kind)],
                [qw(bar 1             2               3  boolean)]
            ],
        },
        {
            sql => 'COMMIT',
            params => [],
        },
    ];
    mock_resultsets($dbh, $mocked_sqls);
    my $expected = [{foo => 'bar', value => 1, kind => 'boolean'}];
    $t->get_ok('/entity/1')->status_is(200)->json_is($expected);
    verify_run_sql($dbh, $mocked_sqls);
};

sub mock_resultsets {
    my ($dbh, $mocked_sqls) = @_;
    foreach my $mocked_sql (@$mocked_sqls) {
        if ($mocked_sql->{results}) {
            $dbh->{mock_add_resultset} = {
                sql => $mocked_sql->{sql},
                results => $mocked_sql->{results},
            };
        }
    }
}

sub verify_run_sql {
    my ($dbh, $mocked_sqls) = @_;
    my $sql_history = $dbh->{mock_all_history_iterator};
    foreach my $mocked_sql (@$mocked_sqls) {
        my $next = $sql_history->next;
        is $next->statement, $mocked_sql->{sql}, "sql";
        eq_or_diff $next->bound_params, $mocked_sql->{params}, "params";
    }
    $next = $sql_history->next;
    is $next, undef, "Last sql executed" or diag $next->statement;
}


done_testing;
