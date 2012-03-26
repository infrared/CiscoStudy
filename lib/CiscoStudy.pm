package CiscoStudy;

use Database::Main;
use Dancer::Plugin::DBIC;
use List::Util 'shuffle';
use Dancer ':syntax';

our $VERSION = '0.1';

get '/' => sub {
    template 'index.tt';
};

get '/subnet-calculator' => sub {
	template 'subnet-calculator';
};
post '/subnet-calculator' => sub {
	template 'subnet-calculator';
};

get '/irc' => sub {
	template 'irc.tt';
};
get '/subnetting-how-to' => sub {
	template 'subnetting.tt';
};

get '/quiz-cisco-multiple-choice' => sub {
	
	my $id = 24;
	
	my $search = schema->resultset('MCQuestions')->find($id);
    if ($search) {
    
		var question => $search->question;
        my $options = schema->resultset('MCOptions')->search({ parent_id => $id });
        my @ids;
        my $hash = {};
        while(my $row = $options->next) {
			push(@ids,$row->mco_id);
            $hash->{$row->mco_id}{option} = $row->options;
        }
        my @shuffled = shuffle(@ids);
		var options => \@shuffled;
	}
	template 'quiz-multiple-choice';
	
};

true;
