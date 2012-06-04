package Database::Main::Result::ForumTopic;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_topic');
__PACKAGE__->add_columns(qw/
    topic_id
    forum_id
    topic_created
    topic_title
    threads
    posts
	
/);
__PACKAGE__->set_primary_key('topic_id');

1;
=cut
mysql> describe forum_topic;
+---------------+------------------+------+-----+---------+----------------+
| Field         | Type             | Null | Key | Default | Extra          |
+---------------+------------------+------+-----+---------+----------------+
| topic_id      | int(11)          | NO   | PRI | NULL    | auto_increment |
| forum_id      | int(10) unsigned | NO   |     | NULL    |                |
| topic_created | int(14) unsigned | NO   |     | NULL    |                |
| topic_title   | varchar(250)     | NO   |     | NULL    |                |
| threads       | int(10) unsigned | YES  |     | 0       |                |
| posts         | int(10) unsigned | YES  |     | 0       |                |
+---------------+------------------+------+-----+---------+----------------+
6 rows in set (0.00 sec)








