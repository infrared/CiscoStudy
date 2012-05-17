package CiscoStudy::Routes::IRC;

use strict;
use warnings;
use Dancer ':syntax';




get '/irc' => sub {
	template 'irc.tt';
};

1;
