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
use DateTime;
#use DateTime::TimeZone

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
			$search->update({ last_login => time });
            session authenticated => 1;
            session username      => $row->username;
            session user_id       => $row->user_id;
			session role          => $row->role;
			session timezone	  => $row->timezone;
			
			
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

get '/c/categories' => sub {
	if (session('moderator')) {
		var categories => &categories;
		template 'categories.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
get '/c/new-category' => sub {
	if (session('moderator')) {
		template 'new-category.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
post '/c/new-category' => sub {
	if (session('moderator')) {
		my $category = param 'category';
		my $search = schema->resultset('Category')->search({ category => $category });
		if ($search->count) {
			var cat_exists => 1;
	
		}
		else {
			my $insert = schema->resultset('Category')->create({ category => $category });
			if ($insert->id) {
				var success => 1;
			}
		}
		template 'new-category.tt';
	}
	else {
		template 'permission-denied.tt';
	}
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
	my $user = schema->resultset('Users')->find($user_id)->update({ timezone => $timezone });
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

get '/c/change-picture' => sub {
	template 'change-picture.tt';
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

get '/c/users' => sub {
	if (session('admin')) {
		
		
		my $search = schema->resultset('Users')->search;
		
		if ($search->count) {
			my @users;
			while (my $row = $search->next) {
				my $hash = {
					user_id => $row->user_id,
					username => $row->username,
					email => $row->email,
					date_joined => $row->date_joined,
					last_login => $row->last_login,
					timezone => $row->timezone,
					role => $row->role,
					
					
				};
				push (@users,$hash);
			}
			var users => \@users;
			
		}
		template 'users.tt';
	}
	else {
		template 'permission-denied';
	}
};

get '/c/new-simple-quiz' => sub {
	if (session('contributor')) {
		var categories => &categories;
		template 'new-simple-quiz.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};

get '/c/simple-quiz-menu' => sub {
    template 'simple-quiz-menu.tt';
    
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
	var categories => &categories;

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
	

	var categories => &categories;
	template 'simple-quiz-show.tt';
	
};
get '/c/edit-multiple-choice-quiz/*' => sub {
	my ($id) = splat;
	
	my $find = schema->resultset('MCQuiz')->find($id);
	
	if ($find) {
		
		my $question = $find->question;
		my $answer   = $find->answer;
		
		my $options = schema->resultset('MCQuizOption')->search({ parent_id => $id });
        my @ids;
        
        while(my $row = $options->next) {
			my $hash;
			$hash->{id} = $row->mco_id;
			$hash->{option} = $row->options;
			push(@ids,$hash);
           
        }
		var question => $question;
		var answer   => $answer;
		var options  => \@ids;
	}
	template 'edit-multiple-choice-quiz.tt';
	
	
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


get '/c/new-multiple-choice-quiz' => sub {
	var categories => &categories;
    template 'new-multiple-choice-quiz.tt';
};

post '/c/new-multiple-choice-quiz' => sub {
	
	my $trap;
	my $newfile;
	if(  my $file  = request->upload('upfile') ) {
		
		my $type = $file->type;
		my $size = $file->size;
		my @allowed = ('image/jpeg');
		if (grep($type eq $_, @allowed)) {
			
			if ($size < 524288) {
				
				my ($ext) = ($type =~ /^image\/(jpeg|gif|png)/);
				$newfile = time . ".$ext";
		
				$file->copy_to("/home/infrared/dev/CiscoStudy/public/images/mc_quiz/$newfile");
			}
			else {
				var size_error => 1;
				$trap++;
				
			}
		}
		else {
			var invalid_type => 1;
			$trap++;
		}
	}

	
	if (!$trap) {

		my @answers;
		my $ids = param 'id';
		
		if ($ids) {
	
			if (ref $ids ne 'ARRAY') {
				push (@answers,$ids);
			}
			else {
				@answers = @{$ids};
			}
			
			
			
			my ($options) =  param 'option';
			
			if (ref $options eq 'ARRAY') {
			
			
								
				foreach(@answers) {
					if (!length @$options[$_ - 1]) {
						var empty_option => 1;
						$trap++;
					}
					
				}
				my $x = 0;
				foreach (@$options) {
					delete @$options[$x] unless length @$options[$x];
					$x++;
				}
				
				if (!$trap) {
					
					my $user_id 	= session 'user_id';
					my $category 	= param 'category';
					my $cert_level 	= param 'cert_level';
					my $question 	= param 'question';
					
					if (length $question) {
						
	
						my $time = time;
		
						my $data = {
							question => $question,
							image => $newfile,
							date_created => $time,
							answer => '',
							category => $category,
							cert_level => $cert_level,
							contributor => $user_id,
						};
	
						my $insert = schema->resultset('MCQuiz')->create($data);
						if ($insert->id) {
							my @answers_update;
							my $parent_id = $insert->id;
							var id => $parent_id;
							my $x = 1;
							foreach my $option (@{ $options }) {
								my $insert_o = schema->resultset('MCQuizOption')->create({
									parent_id => $parent_id,
									mc_option => $option,
								});
								if (grep($x == $_,@answers)) {
									push(@answers_update,$insert_o->id);
								}
								$x++;
							}
							my $answer_update = join(',', @answers_update);
							$insert->update({ answer => $answer_update });
						}
					}
					else {
						var invalid_form => 1;
					}
				}
				else {
					var invalid_form => 1;
				}
			}
			else {
				var invalid_form => 1;
			}
		}
		else {
			var invalid_form => 1;
		}
	}
	else {
		var invalid_form => 1;
	}
	var categories => &categories;
	
	template 'new-multiple-choice-quiz.tt';
	
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
		my $all = schema->resultset('MCQuiz')->search;
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
	
	
	my $search = schema->resultset('MCQuiz')->find($id);
    if ($search) {
    
	var question => $search->question;
        my $options = schema->resultset('MCQuizOption')->search({ parent_id => $id });
        my @ids;
        
        while(my $row = $options->next) {
			my $hash;
			$hash->{id} = $row->mco_id;
			$hash->{option} = $row->mc_option;
			push(@ids,$hash);
           
        }
        my @shuffled = shuffle(@ids);
		var id => $id;
		var options => \@shuffled;
#		use Data::Dumper;
#		var list => Dumper session('list');
	}
	template 'quiz-multiple-choice';
	
};
get '/cisco-quiz-multiple-choice/*' => sub {
	
	my ($id) = splat;
	
	
	my $search = schema->resultset('MCQuiz')->find($id);
    if ($search) {
    
	var question => $search->question;
	var image    => $search->image;
        my $options = schema->resultset('MCQuizOption')->search({ parent_id => $id });
        my @ids;
        
        while(my $row = $options->next) {
			my $hash;
			$hash->{id} = $row->mco_id;
			$hash->{option} = $row->mc_option;
			push(@ids,$hash);
           
        }
        my @shuffled = shuffle(@ids);
		var id => $id;
		var options => \@shuffled;
#		use Data::Dumper;
#		var list => Dumper session('list');
	}
	template 'quiz-multiple-choice';
	
};
post '/cisco-quiz-multiple-choice' => sub {
	my $id = param 'id';
	my $guess = param 'option';
	
	my @guesses;
	if (ref $guess eq 'ARRAY') {
	    @guesses = @{ $guess };
	    
	}
	else {
	    push(@guesses,$guess);
	}
    
	
	my $search = schema->resultset('MCQuiz')->find($id);
	my (@answers) = ($search->answer =~ /(\d+)/g);
	
	my $compare = Array::Compare->new;
	
	if ($compare->perm( \@guesses, \@answers)) {
		var correct => "1";
		
	}

	template 'quiz-multiple-choice';
};

sub categories {
	my $cat = schema->resultset('Category')->search;
	my @categories;
	while(my $row = $cat->next) {
		my $hash = {
			id => $row->cat_id,
			category => $row->category,
		};
		push(@categories,$hash);
	}
	
	return \@categories;
}
true;
