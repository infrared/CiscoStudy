package CiscoStudy;

use Database::Main;
use Dancer::Plugin::DBIC;
use List::Util 'shuffle';
use Dancer ':syntax';
use Array::Compare;

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

get '/cisco-quiz-multiple-choice' => sub {
	
	if (!session('start')) {
		session start => time;
	}
	else {
		my $now = time;
		if ($now - session('start') > 86400) {
			# it's been 24 hrs, restart the timer
			# and clear the list of MC questions
			session start => $now;
			session list => undef;
			
		}
		else {
			# update the timer
			session start => $now;
			
			
		}
	}
	if (!session('list')) {
		my $all = schema->resultset('MCQuestions')->search;
		if ($all->count) {
			my @list;
			while (my $row = $all->next) {
				push(@list,$row->mc_id);
			}
			session list => \@list;
		}
	}
	
	my $list = session('list');
	
	my $random = int rand (scalar @{ $list });
	
	my $id = @$list[$random];
	splice(@$list, $random,1);
	
	session list => $list;
	
	
	my $search = schema->resultset('MCQuestions')->find($id);
    if ($search) {
    
		var question => $search->question;
        my $options = schema->resultset('MCOptions')->search({ parent_id => $id });
        my @ids;
        
        while(my $row = $options->next) {
			my $hash;
			$hash->{id} = $row->mco_id;
			$hash->{option} = $row->options;
			push(@ids,$hash);
           
        }
        my @shuffled = shuffle(@ids);
		var id => $id;
		var options => \@shuffled;
		use Data::Dumper;
		var list => Dumper session('list');
	}
	template 'quiz-multiple-choice';
	
};
post '/cisco-quiz-multiple-choice' => sub {
	my $id = param 'id';
	my $guess = param 'option';
	
	my @guesses;
	
	
	my $search = schema->resultset('MCQuestions')->find($id);
	my (@answers) = ($search->answer =~ /(\d+)/g);
	
	my $compare = Array::Compare->new;
	
	if ($compare->perm( $guesses, \@answers)) {
		var correct => "1";
		
	}

	template 'quiz-multiple-choice';
};

true;
