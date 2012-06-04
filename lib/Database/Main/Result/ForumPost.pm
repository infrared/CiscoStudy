package Database::Main::Result::ForumPost;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_post');
__PACKAGE__->add_columns(qw/
    thread_id
    post_id
    post_created
    post
    user_id
    
/);
__PACKAGE__->set_primary_key('post_id');

1;
=cut
mysql> describe forum_post;
+--------------+------------------+------+-----+---------+----------------+
| Field        | Type             | Null | Key | Default | Extra          |
+--------------+------------------+------+-----+---------+----------------+
| post_id      | int(11)          | NO   | PRI | NULL    | auto_increment |
| thread_id    | int(10) unsigned | NO   |     | NULL    |                |
| post_created | int(14) unsigned | NO   |     | NULL    |                |
| post         | blob             | NO   |     | NULL    |                |
| user_id      | int(10) unsigned | NO   |     | NULL    |                |
+--------------+------------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)







