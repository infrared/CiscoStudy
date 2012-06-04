package Database::Main::Result::ForumPostView;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_post_view');
__PACKAGE__->add_columns(qw/
    post_id
    thread_id
    post_created
    user_id
    topic_id
    forum_id
    post
    
/);
#__PACKAGE__->set_primary_key('post_id');

1;
=cut
mysql> describe forum_post_view;
+--------------+------------------+------+-----+---------+-------+
| Field        | Type             | Null | Key | Default | Extra |
+--------------+------------------+------+-----+---------+-------+
| post_id      | int(11)          | NO   |     | 0       |       |
| thread_id    | int(10) unsigned | NO   |     | NULL    |       |
| post_created | int(14) unsigned | NO   |     | NULL    |       |
| user_id      | int(10) unsigned | NO   |     | NULL    |       |
| topic_id     | int(11)          | YES  |     | 0       |       |
| forum_id     | int(11)          | YES  |     | 0       |       |
| post         | blob             | NO   |     | NULL    |       |
+--------------+------------------+------+-----+---------+-------+
7 rows in set (0.00 sec)






