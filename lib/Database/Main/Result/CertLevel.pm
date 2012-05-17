package Database::Main::Result::CertLevel;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('cert_level');
__PACKAGE__->add_columns(qw/
	cert_id
	cert_name
/);
__PACKAGE__->set_primary_key('cert_id');

1;
=cut
mysql> describe cert_level;
+-----------+--------------+------+-----+---------+----------------+
| Field     | Type         | Null | Key | Default | Extra          |
+-----------+--------------+------+-----+---------+----------------+
| cert_id   | int(11)      | NO   | PRI | NULL    | auto_increment |
| cert_name | varchar(250) | NO   |     | NULL    |                |
+-----------+--------------+------+-----+---------+----------------+
2 rows in set (0.00 sec)


