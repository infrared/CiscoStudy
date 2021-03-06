package CiscoStudy::Object::User;
use strict;
use warnings;

use Dancer::Plugin::DBIC;
use Dancer ':syntax';
use URI::Escape qw(uri_escape);
use Digest::MD5 qw(md5_hex);
use Crypt::PasswdMD5;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub get_user {
	my ($self,$user_id) = @_;
	my $user = schema->resultset('User')->find($user_id);
	

    my $username = $user->username;

    my ($first) = ($username =~ /(\w)/);
	$first = lc $first;
	my $avatar_method = $user->avatar_method;
	my $avatar_value  = $user->avatar_value;
    #print "OMG VALUE: $avatar_value\n";
	my $avatar;
	if ($avatar_method eq 'disk') {
		$avatar = "/images/avatar/$first/". $avatar_value;
	}
	elsif ($avatar_method eq 'gravatar') {
		my $default;
		my $size = 85;
		$avatar = "http://www.gravatar.com/avatar/". $avatar_value;# "\?d=".uri_escape($default). "\&s=".$size;
	}
	else {
		$avatar = undef;
	}
    
    my $date_joined = $user->date_joined;
    my $last_login  => $user->last_login;
    
    my $now = time;
    
    
    if (defined($date_joined)) {
        $date_joined = &date($date_joined);
    }
    else {
        $date_joined = 0; 
    }
    if (defined($last_login)) {
        $last_login = &date($last_login);
    }
    else {
        $last_login = 0;
    }
    

    
	my $hash = {
        user_id => $user_id,
		username => $username,
        email => $user->email,
		avatar_method => $avatar_method,
		avatar_value   => $avatar_value,
		avatar => $avatar,
        date_joined => $date_joined,
        last_login => $last_login,
        timezone => $user->timezone,
        quiz_contributions => $user->quiz_contributions,
        forum_posts => $user->forum_posts,
        role => $user->role,
        
		
	};
	
	return $hash;
}


sub change_password {
    my ($self,$user_id,$password) = @_;
    my $hash = unix_md5_crypt($password);
	my $user = schema->resultset('User')->find($user_id)->update({ password => $hash });
    return 1 if $user->id;
    return 0;
}
sub change_email {
    my ($self,$user_id,$email) = @_;
    my $user = schema->resultset('User')->find($user_id)->update({ email => $email });
    return 1 if $user->id;
    return 0;
}
sub update_avatar {
    my ($self,$user_id,$details) = @_;
    my $user = schema->resultset('User')->find($user_id)->update($details);
    return 1 if $user->id;
    return 0;
    
}
sub date {
	
	my ($epoch) = shift;
	if (length session('timezone')) {
		
		my $dt = DateTime->from_epoch( epoch => $epoch )->set_time_zone( session('timezone') );
		
							   
		return sprintf("%3s %02d, %04d - %02d:%02d:%02d", $dt->month_abbr,$dt->day, $dt->year,$dt->hour,$dt->min,$dt->sec);

						   
	}
	else {
		return 0;
	}
	
	
}


1;
