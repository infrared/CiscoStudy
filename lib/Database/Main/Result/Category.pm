package Database::Main::Result::Category;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('category');
__PACKAGE__->add_columns(qw/
	cat_id
    cert_level
	category
/);
__PACKAGE__->set_primary_key('cat_id');

1;
=cut
mysql> describe category;
+------------+------------------+------+-----+---------+----------------+
| Field      | Type             | Null | Key | Default | Extra          |
+------------+------------------+------+-----+---------+----------------+
| cat_id     | int(11)          | NO   | PRI | NULL    | auto_increment |
| cert_level | int(10) unsigned | NO   |     | NULL    |                |
| category   | varchar(250)     | NO   |     | NULL    |                |
+------------+------------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)


