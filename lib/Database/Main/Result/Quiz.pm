package Database::Main::Result::Quiz;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('quiz');
__PACKAGE__->add_columns(qw/
	quiz_id
    date_created
    quiz_type
	question
    image
	answer
    answer_ios
	category
    cert_level
    contributor
/);
__PACKAGE__->set_primary_key('quiz_id');

1;
=cut


mysql> describe quiz;
+--------------+------------------+------+-----+---------+----------------+
| Field        | Type             | Null | Key | Default | Extra          |
+--------------+------------------+------+-----+---------+----------------+
| quiz_id      | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| date_created | int(14) unsigned | NO   |     | NULL    |                |
| quiz_type    | varchar(2)       | NO   |     | NULL    |                |
| question     | text             | NO   |     | NULL    |                |
| image        | varchar(250)     | YES  |     | NULL    |                |
| answer       | varchar(250)     | NO   |     | NULL    |                |
| answer_ios   | int(1) unsigned  | YES  |     | 0       |                |
| category     | varchar(250)     | NO   |     | NULL    |                |
| cert_level   | int(10) unsigned | NO   |     | NULL    |                |
| contributor  | int(14) unsigned | NO   |     | NULL    |                |
+--------------+------------------+------+-----+---------+----------------+
10 rows in set (0.01 sec)



