package Database::Main::Result::User;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/
	user_id
	username
    email
    avatar_method
    avatar_value
    date_joined
    last_login
    timezone
	raw_nick
	password
	role
    quiz_contributions
    forum_posts
	
/);
__PACKAGE__->set_primary_key('user_id');

1;
=cut
mysql> describe user;
+--------------------+------------------+------+-----+---------+----------------+
| Field              | Type             | Null | Key | Default | Extra          |
+--------------------+------------------+------+-----+---------+----------------+
| user_id            | int(11)          | NO   | PRI | NULL    | auto_increment |
| username           | varchar(250)     | NO   |     | NULL    |                |
| email              | varchar(250)     | NO   |     | NULL    |                |
| avatar_method      | varchar(250)     | NO   |     | NULL    |                |
| avatar_value       | varchar(250)     | NO   |     | NULL    |                |
| date_joined        | int(14) unsigned | NO   |     | NULL    |                |
| last_login         | int(14) unsigned | NO   |     | NULL    |                |
| timezone           | varchar(250)     | NO   |     | NULL    |                |
| raw_nick           | varchar(250)     | NO   |     | NULL    |                |
| password           | varchar(250)     | NO   |     | NULL    |                |
| role               | varchar(250)     | YES  |     | none    |                |
| quiz_contributions | int(10) unsigned | NO   |     | 0       |                |
| forum_posts        | int(10) unsigned | NO   |     | 0       |                |
+--------------------+------------------+------+-----+---------+----------------+
13 rows in set (0.00 sec)




