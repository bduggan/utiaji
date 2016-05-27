use Utiaji::DB;

sub clear-db is export {
    my $db = Utiaji::DB.new;
    $db.query('delete from kk');
    $db.query('delete from kv');
}
