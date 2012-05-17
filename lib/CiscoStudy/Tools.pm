package CiscoStudy::Tools;
use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Dancer::Plugin::DBIC;
use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub get_user {
	my ($self,$user_id) = @_;
	my $user = schema->resultset('Users')->find($user_id);
	
	my $email = $user->email;
	
	my $avatar_method = $user->avatar_method;
	my $avatar_value  = $user->avatar_value;
	my $avatar;
	if ($avatar_method eq 'disk') {
		$avatar = '/images/avatar/'. $avatar_value;
	}
	elsif ($avatar_method eq 'gravatar') {
		my $default;
		my $size = 40;
		$avatar = "http://www.gravatar.com/avatar/". $avatar_value. "\?d=".uri_escape($default). "\&s=".$size;
	}
	else {
		$avatar = undef;
	}
	my $hash = {
		username => $user->username,
		avatar_method => $user->avatar_method,
		avatar_value   => $user->avatar_value,
		avatar => $avatar,
		
	};
	
	return $hash;
}


1;
