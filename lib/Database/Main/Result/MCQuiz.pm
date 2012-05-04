package Database::Main::Result::MCQuiz;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('mc_quiz');
__PACKAGE__->add_columns(qw/
	mc_id
    date_created
	question
    image
	answer
	category
    cert_level
    contributor
/);
__PACKAGE__->set_primary_key('mc_id');

1;
=cut


mysql> describe mc_quiz;
+--------------+------------------+------+-----+---------+----------------+
| Field        | Type             | Null | Key | Default | Extra          |
+--------------+------------------+------+-----+---------+----------------+
| mc_id        | int(11)          | NO   | PRI | NULL    | auto_increment |
| date_created | int(14) unsigned | NO   |     | NULL    |                |
| question     | text             | NO   |     | NULL    |                |
| image        | varchar(250)     | YES  |     | NULL    |                |
| answer       | varchar(250)     | NO   |     | NULL    |                |
| category     | varchar(250)     | NO   |     | NULL    |                |
| cert_level   | varchar(250)     | NO   |     | NULL    |                |
| contributor  | varchar(250)     | NO   |     | NULL    |                |
+--------------+------------------+------+-----+---------+----------------+
8 rows in set (0.01 sec)

