package CiscoStudy::Routes::Login;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Crypt::PasswdMD5;

get '/login' => sub {
    template 'login.tt';
};
post '/login' => sub {
    my $username = param 'username';
    my $password = param 'password';
    
    my @errors;
    
    
    my $search = schema->resultset('User')->search({
     	username => $username
    });
	if ($search->count) {
    	my $row    = $search->first;
    	my $stored = $row->password;
		
		var username => $username;
		var password => $password;
		var stored   => $stored;
		
		var mine => unix_md5_crypt($password,$stored);
        if ($stored eq unix_md5_crypt($password,$stored)) {
			$search->update({ last_login => time });
            session authenticated => 1;
            session username      => $row->username;
            session user_id       => $row->user_id;
			session role          => $row->role;
			session timezone	  => $row->timezone;
			#session avatar_method => $row->avatar_method;
			#session avatar_value  => $row->avatar_value;
			
			# avatar
=cut			
			if ($row->avatar_method eq 'disk') {
				session avatar => '<img src="/images/avatar/' . $row->avatar_value . '" />';
			}
			elsif ($row->avatar_method eq 'email') {
				my $default;
				my $size = 40;
				session avatar => "http://www.gravatar.com/avatar/". md5_hex(lc $row->email). "\?d=".uri_escape($default). "\&s=".$size;
			}
			else {
				session avatar => '';
			}
=cut
			
			
			if ($row->role eq 'admin') {
				session admin	  => 1;
				session moderator => 1;
				session contributor => 1;
			}
			elsif ($row->role eq 'moderator') {
				session moderator => 1;
				session contributor => 1;
			}
			elsif($row->role eq 'contributor') {
				session contributor => 1;
			}
			
            redirect '/';
        }
        else {
            push (@errors, "Invalid username or password");
                       
        }
    }
	
    else {
        push (@errors, "Login Failed");
        
    }
    var errors => \@errors;
    template 'login.tt';

};
1;
