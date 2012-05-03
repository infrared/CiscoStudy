package Database::Main::Result::Category;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('category');
__PACKAGE__->add_columns(qw/
	cat_id
	category
/);
__PACKAGE__->set_primary_key('cat_id');

1;
=cut
mysql> describe categories;
+----------+--------------+------+-----+---------+----------------+
| Field    | Type         | Null | Key | Default | Extra          |
+----------+--------------+------+-----+---------+----------------+
| cat_id   | int(11)      | NO   | PRI | NULL    | auto_increment |
| category | varchar(250) | NO   |     | NULL    |                |
+----------+--------------+------+-----+---------+----------------+
2 rows in set (0.00 sec)

