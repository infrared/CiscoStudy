package Database::Main::Result::ForumPost;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_post');
__PACKAGE__->add_columns(qw/
    thread_id
    post_id
    post_created
    post
    post_edit
    post_edit_date
    post_edit_reason
    post_edit_user_id
    user_id
    
/);
__PACKAGE__->set_primary_key('post_id');

1;
=cut
mysql> describe forum_post;
+-------------------+------------------+------+-----+---------+----------------+
| Field             | Type             | Null | Key | Default | Extra          |
+-------------------+------------------+------+-----+---------+----------------+
| post_id           | int(11)          | NO   | PRI | NULL    | auto_increment |
| thread_id         | int(10) unsigned | NO   |     | NULL    |                |
| post_created      | int(14) unsigned | NO   |     | NULL    |                |
| post              | blob             | NO   |     | NULL    |                |
| post_edit         | int(1) unsigned  | YES  |     | 0       |                |
| post_edit_date    | int(15) unsigned | YES  |     | 0       |                |
| post_edit_reason  | varchar(250)     | YES  |     | NULL    |                |
| post_edit_user_id | int(5) unsigned  | YES  |     | 0       |                |
| user_id           | int(10) unsigned | NO   |     | NULL    |                |
+-------------------+------------------+------+-----+---------+----------------+
9 rows in set (0.00 sec)









