package CiscoStudy::Routes::Logout;

use strict;
use warnings;
use Dancer ':syntax';




get '/logout' => sub {
    session->destroy;
	my $hash = session;
    redirect '/';
};


1;
