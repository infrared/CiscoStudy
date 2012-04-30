package CiscoStudy;

use Database::Main;
use Dancer::Plugin::DBIC;
use List::Util 'shuffle';
use Dancer ':syntax';
use Array::Compare;
use Crypt::PasswdMD5;
use URI::Escape qw(uri_escape);
use Digest::MD5 qw(md5_hex);
use Email::Valid;

our $VERSION = '0.1';

hook 'before' => sub {
    if (request->path_info =~ m{^/c\/} && !session('authenticated') ) {
        request->path_info('/login');
    }
};
get '/login' => sub {
    template 'login.tt';
};
post '/login' => sub {
    my $username = param 'username';
    my $password = param 'password';
    
    my @errors;
    
    
    my $search = schema->resultset('Users')->search({
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
            session authenticated => 1;
            session username      => $row->username;
            session user_id       => $row->user_id;
			session role          => $row->role;
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
get '/profile' => sub {
	my $user_id = session 'user_id';
	my $email = 'michael@kroher.net';
	my $default;
	my $size = 40;

    my $gravitar = "http://www.gravatar.com/avatar/". md5_hex(lc $email). "\?d=".uri_escape($default). "\&s=".$size;
	var gravitar => $gravitar;
	template 'profile.tt';
};

get '/logout' => sub {
    session->destroy;
	my $hash = session;
    redirect '/';
};
get '/c/test' => sub {
	template 'index.tt';
};


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
get '/how-to-calculate-network-address' => sub {
	template 'calculate-network-address.tt';
};


get '/c/change-email' => sub {
	template 'change-email.tt';
};
post '/c/change-email' => sub {
	my $email = param 'email';
	my $user_id = session 'user_id';
	
	if (Email::Valid->address($email)) {
	
		my $user = schema->resultset('Users')->find($user_id)->update({ email => $email });
		if ($user) {
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
get '/c/change-password' => sub {
	template 'change-password.tt';
};
post '/c/change-password' => sub {
	my $password1 = param 'password1';
	my $password2 = param 'password2';
	my $user_id = session 'user_id';
	
	if (length $password1 > 4) {
		if ($password1 eq $password2) {
			my $hash = unix_md5_crypt($password1);
			my $user = schema->resultset('Users')->find($user_id)->update({ password => $hash });
			if ($user) {
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

get '/c/new-simple-quiz' => sub {
	template 'new-simple-quiz.tt';
};
get '/c/simple-quiz-show' => sub {
		my $search = schema->resultset('SimpleQuiz')->search;
		if ($search->count) {
		my @rows;
		while (my $row = $search->next) {
			my $hash = {
				id => $row->quiz_id,
				question => $row->question,
				answer => $row->answer,
			};
			push(@rows,$hash);
			
		}
		var rows => \@rows;
	}	
	my $filter = schema->resultset('SimpleQuiz')->search(
		undef,
		{
			columns => [ qw/ category /],
			distinct => 1,

		}
	);
	my @categories;
	while(my $row = $filter->next) {
		push(@categories,$row->category);
	}
	var categories => \@categories;

	template 'simple-quiz-show.tt';

};
post '/c/simple-quiz-show' => sub {
	
	my $category = param 'category';
	my $cert_level = param 'cert_level';
	
	my $search = schema->resultset('SimpleQuiz')->search({
		category => $category,
		cert_level => $cert_level,
	});
	
	if ($search->count) {
		my @rows;
		while (my $row = $search->next) {
			my $hash = {
				id => $row->quiz_id,
				question => $row->question,
				answer => $row->answer,
			};
			push(@rows,$hash);
			
		}
		var rows => \@rows;
	}
	
	my $filter = schema->resultset('SimpleQuiz')->search(
		undef,
		{
			columns => [ qw/ category /],
			distinct => 1,

		}
	);
	my @categories;
	while(my $row = $filter->next) {
		push(@categories,$row->category);
	}
	var categories => \@categories;
	template 'simple-quiz-show.tt';
	
};
post '/c/new-simple-quiz' => sub {
	
	my $cert_level = param 'cert_level';
	my $category   = param 'category';
	my $question   = param 'question';
	my $answer     = param 'answer';
	my $user_id    = session 'user_id';
	
	if ( length $cert_level && length $category && length $question && length $answer) {

		my $insert = schema->resultset('SimpleQuiz')->create({
			cert_level => $cert_level,
			category   => $category,
			question   => $question,
			answer     => $answer,
			contributor => $user_id,
		});
		if ($insert->id) {
			var success => 1;
			var id => $insert->id;
		}
		else {
			var error => 1;
		}
	}
	else {
		var formerror => 1;
	}
	
	template 'new-simple-quiz';
	
	
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
=cut
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
=cut
true;
