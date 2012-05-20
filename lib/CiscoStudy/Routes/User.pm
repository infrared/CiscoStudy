package CiscoStudy::Routes::User;

use strict;
use warnings;
use Dancer ':syntax';


use CiscoStudy::Object::User;
use Dancer::Plugin::DBIC;

my $u_obj = CiscoStudy::Object::User->new;



get '/c/users' => sub {
	if (session('moderator')) {
				
		my $search = schema->resultset('User')->search;
		
		if ($search->count) {
			my @users;
			while (my $row = $search->next) {
				my $user = $u_obj->get_user($row->user_id);

				push (@users,$user);
			}
			var users => \@users;
			
		}
		template 'users.tt';
	}
	else {
		template 'permission-denied';
	}
};





1;
