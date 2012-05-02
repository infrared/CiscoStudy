package Database::Main::Result::MCQuizOption;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('mc_quiz_option');
__PACKAGE__->add_columns(qw/
	mco_id
	parent_id
	mc_option
/);
__PACKAGE__->set_primary_key('mco_id');

1;
=cut
mysql> describe mc_quiz_option;
+-----------+------------------+------+-----+---------+----------------+
| Field     | Type             | Null | Key | Default | Extra          |
+-----------+------------------+------+-----+---------+----------------+
| mco_id    | int(11)          | NO   | PRI | NULL    | auto_increment |
| parent_id | int(10) unsigned | NO   |     | NULL    |                |
| mc_option | text             | NO   |     | NULL    |                |
+-----------+------------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)


