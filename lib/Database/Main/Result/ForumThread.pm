package Database::Main::Result::ForumThread;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_thread');
__PACKAGE__->add_columns(qw/
    thread_id
    topic_id
    thread_title
    thread_posts
    thread_views
    thread_created
    user_id
    
/);
__PACKAGE__->set_primary_key('thread_id');

1;
=cut
mysql> describe forum_thread;
+----------------+------------------+------+-----+---------+----------------+
| Field          | Type             | Null | Key | Default | Extra          |
+----------------+------------------+------+-----+---------+----------------+
| thread_id      | int(11)          | NO   | PRI | NULL    | auto_increment |
| topic_id       | int(10) unsigned | NO   |     | NULL    |                |
| thread_title   | varchar(250)     | NO   |     | NULL    |                |
| thread_posts   | int(10) unsigned | YES  |     | 0       |                |
| thread_views   | int(10) unsigned | YES  |     | 0       |                |
| thread_created | int(15) unsigned | NO   |     | NULL    |                |
| user_id        | int(10) unsigned | NO   |     | NULL    |                |
+----------------+------------------+------+-----+---------+----------------+
7 rows in set (0.00 sec)







