package CiscoStudy::Routes::Profile;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use CiscoStudy::Object::User;
use CiscoStudy::Object::User::Image;
use Email::Valid;

use Digest::MD5 qw(md5_hex);


my $u_obj = CiscoStudy::Object::User->new;
my $i_obj = CiscoStudy::Object::User::Image->new;


get '/c/profile' => sub {
	my $user_id = session('user_id');
	
	var user => $u_obj->get_user($user_id);
	template 'profile.tt';
};


get '/c/change-password' => sub {
	template 'change-password.tt';
};
post '/c/change-password' => sub {
	my $password1 = param 'password1';
	my $password2 = param 'password2';
	my $user_id   = session 'user_id';
	
	if (length $password1 > 4) {
        
        
		if ($password1 eq $password2) {
            if ($u_obj->change_password($user_id,$password1)) {

				var success => 1;
			}
			else {
				var error => 1;
			}
		}
		else {
			var mismatch => 1;
		}
			
		
	}
	else {
		var invalid => 1;
	}
	template 'change-password.tt';
};
post '/c/change-email' => sub {
	my $email = param 'email';
	my $user_id = session 'user_id';
	
	if (Email::Valid->address($email)) {
        if ($u_obj->change_email($user_id,$email)) {
			var success => 1;

		}
		else {
			var error => 1;
		}
	}
	else {
	
		var invalid => 1;
	}
	
	
	template 'change-email.tt';
};
get '/c/change-picture' => sub {
	my $user_id = session 'user_id';
	var user => $u_obj->get_user($user_id);
	
	template 'change-picture.tt';
};
post '/c/change-picture' => sub {
	
	my $method = param 'picture';
	my $user_id = session 'user_id';
	my $user = $u_obj->get_user($user_id);
	
	
	if ($method eq 'disk') {
		my $trap;
		my $newfile;
		if(  my $file  = request->upload('upfile') ) {
            
            if (my $image = $i_obj->upload_image($file)) {
		
                if ($u_obj->update_avatar($user_id,{
                    avatar_method => 'disk',
					avatar_value => $image,
				})) {
				
                    var success => 1;
                    redirect '/c/profile';
				}
				else {
					var error => 1;
				}
			}
			else {
                var error => 1;

			}
		}
        
	}
	elsif ($method eq 'gravatar') {
		my $email = $user->{'email'};
		if (!$email) {
			var missing_email => 1;
		}
		else {
			my $default;
			my $size = 40;
			my $avatar_value = md5_hex(lc $email);
            if ($u_obj->update_avatar($user_id,{
				avatar_method => 'gravatar',
				avatar_value => $avatar_value,
			})) {
				var success => 1;
                redirect '/c/profile';
			}
			else {
				var error => 1;
			}
		}
	}
	elsif ($method eq 'none') {
        
        if ($u_obj->update_avatar($user_id,{
			avatar_method => '',
			avatar_value => '',
		})) {
			var success => 1;
            redirect '/c/profile';
		}
		else {
			var error => 1;
		}
	}
	var user => $user;
	template 'change-picture.tt';
};
get '/c/change-timezone' => sub {
	use DateTime::TimeZone;
	my @timezones = DateTime::TimeZone->all_names;
	var timezones => \@timezones;
	
	template 'change-timezone.tt';
};
post '/c/change-timezone' => sub {
	my $user_id = session 'user_id';
	my $timezone = param 'timezone';
	my $user = schema->resultset('User')->find($user_id)->update({ timezone => $timezone });
	if ($user) {
		var success => 1;
		session timezone => $timezone;
	}
	else {
		var error => 1;
	}
	my @timezones = DateTime::TimeZone->all_names;
	var timezones => \@timezones;
	template 'change-timezone.tt';
};
get '/c/change-email' => sub {
	template 'change-email.tt';
};
1;
