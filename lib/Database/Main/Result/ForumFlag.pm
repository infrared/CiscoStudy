package Database::Main::Result::ForumFlag;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum_flag');
__PACKAGE__->add_columns(qw/

    flag_id
    post_id
    reason
    comment
    user_id
    flag_date
    status
/);
__PACKAGE__->set_primary_key('flag_id');

1;
=cut
mysql> describe forum_flag;
+-----------+------------------+------+-----+---------+----------------+
| Field     | Type             | Null | Key | Default | Extra          |
+-----------+------------------+------+-----+---------+----------------+
| flag_id   | int(11)          | NO   | PRI | NULL    | auto_increment |
| post_id   | int(10) unsigned | NO   |     | NULL    |                |
| reason    | varchar(250)     | NO   |     | NULL    |                |
| comment   | blob             | YES  |     | NULL    |                |
| user_id   | int(10) unsigned | NO   |     | NULL    |                |
| flag_date | int(15) unsigned | NO   |     | NULL    |                |
| status    | varchar(250)     | YES  |     | pending |                |
+-----------+------------------+------+-----+---------+----------------+
7 rows in set (0.01 sec)








