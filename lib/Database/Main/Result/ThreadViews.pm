package Database::Main::Result::ThreadViews;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('thread_views');
__PACKAGE__->add_columns(qw/

    view_id
    thread_id
    views
/);
__PACKAGE__->set_primary_key('view_id');

1;
=cut
mysql> describe thread_views;
+-----------+------------------+------+-----+---------+----------------+
| Field     | Type             | Null | Key | Default | Extra          |
+-----------+------------------+------+-----+---------+----------------+
| id        | int(11)          | NO   | PRI | NULL    | auto_increment |
| thread_id | int(10) unsigned | NO   |     | NULL    |                |
| views     | int(10) unsigned | NO   |     | NULL    |                |
+-----------+------------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)









