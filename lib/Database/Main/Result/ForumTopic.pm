package Database::Main::Result::ForumTopic;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_topic');
__PACKAGE__->add_columns(qw/
    topic_id
    forum_id
    topic_created
    topic_title
    topic_desc
    threads
    posts
    last_post_date
    last_post_user_id
	
/);
__PACKAGE__->set_primary_key('topic_id');

1;
=cut
mysql> describe forum_topic;
+-------------------+------------------+------+-----+---------+----------------+
| Field             | Type             | Null | Key | Default | Extra          |
+-------------------+------------------+------+-----+---------+----------------+
| topic_id          | int(11)          | NO   | PRI | NULL    | auto_increment |
| forum_id          | int(10) unsigned | NO   |     | NULL    |                |
| topic_created     | int(14) unsigned | NO   |     | NULL    |                |
| topic_title       | varchar(250)     | NO   |     | NULL    |                |
| topic_desc        | blob             | YES  |     | NULL    |                |
| threads           | int(10) unsigned | YES  |     | 0       |                |
| posts             | int(10) unsigned | YES  |     | 0       |                |
| last_post_date    | int(15) unsigned | YES  |     | NULL    |                |
| last_post_user_id | int(10) unsigned | YES  |     | NULL    |                |
+-------------------+------------------+------+-----+---------+----------------+
9 rows in set (0.00 sec)

mysql> 










