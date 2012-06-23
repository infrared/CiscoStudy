package Database::Main::Result::ForumThread;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_thread');
__PACKAGE__->add_columns(qw/
    thread_id
    topic_id
    thread_title
    thread_post
    thread_posts
    thread_views
    thread_created
    user_id
    last_post_date
    last_post_user_id
    sticky
    locked
    
/);
__PACKAGE__->set_primary_key('thread_id');

1;
=cut
mysql> describe forum_thread;
+-------------------+------------------+------+-----+---------+----------------+
| Field             | Type             | Null | Key | Default | Extra          |
+-------------------+------------------+------+-----+---------+----------------+
| thread_id         | int(11)          | NO   | PRI | NULL    | auto_increment |
| topic_id          | int(10) unsigned | NO   |     | NULL    |                |
| thread_title      | varchar(250)     | NO   |     | NULL    |                |
| thread_post       | blob             | NO   |     | NULL    |                |
| thread_posts      | int(10) unsigned | YES  |     | 0       |                |
| thread_views      | int(10) unsigned | YES  |     | 0       |                |
| thread_created    | int(15) unsigned | NO   |     | NULL    |                |
| user_id           | int(10) unsigned | NO   |     | NULL    |                |
| last_post_date    | int(15) unsigned | YES  |     | NULL    |                |
| last_post_user_id | int(10) unsigned | YES  |     | NULL    |                |
| sticky            | int(1) unsigned  | YES  |     | 0       |                |
| locked            | int(1) unsigned  | YES  |     | 0       |                |
+-------------------+------------------+------+-----+---------+----------------+
12 rows in set (0.00 sec)










