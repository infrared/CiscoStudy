package CiscoStudy::Routes::Profile;
use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin::DBIC;


get '/profile' => sub {
	my $user_id = session('user_id');
	
	var user => &get_user($user_id);
	template 'profile.tt';
};
1;
