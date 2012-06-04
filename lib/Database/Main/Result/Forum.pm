package Database::Main::Result::Forum;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('forum');
__PACKAGE__->add_columns(qw/
    forum_id
    forum_created
    forum_title
    last_post_date
    last_post_by
	
/);
__PACKAGE__->set_primary_key('forum_id');

1;
=cut
mysql> describe forum;
+----------------+------------------+------+-----+---------+----------------+
| Field          | Type             | Null | Key | Default | Extra          |
+----------------+------------------+------+-----+---------+----------------+
| forum_id       | int(11)          | NO   | PRI | NULL    | auto_increment |
| forum_created  | int(14) unsigned | NO   |     | NULL    |                |
| forum_title    | varchar(250)     | NO   |     | NULL    |                |
| last_post_date | int(15) unsigned | NO   |     | NULL    |                |
| last_post_by   | int(10) unsigned | NO   |     | NULL    |                |
+----------------+------------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)







