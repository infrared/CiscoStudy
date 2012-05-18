package CiscoStudy;

use Database::Main;
use Dancer::Plugin::DBIC;
use List::Util 'shuffle';
use Dancer ':syntax';
use Array::Compare;
#use Crypt::PasswdMD5;
use URI::Escape qw(uri_escape);
use Digest::MD5 qw(md5_hex);
use Email::Valid;
use DateTime;
use Image::Resize;
#use DateTime::TimeZone

our $VERSION = '0.1';

hook 'before' => sub {
    if (request->path_info =~ m{^/c\/} && !session('authenticated') ) {
        request->path_info('/login');
    }
};

use CiscoStudy::Routes::Index;
use CiscoStudy::Routes::Login;
use CiscoStudy::Routes::Profile;
use CiscoStudy::Routes::Logout;
use CiscoStudy::Routes::IRC;
use CiscoStudy::Routes::CertLevel;
use CiscoStudy::Routes::Category;
use CiscoStudy::Routes::Quiz;

=cut
get '/subnetting-how-to' => sub {
	template 'subnetting.tt';
};
get '/how-to-calculate-network-address' => sub {
	template 'calculate-network-address.tt';
};
=cut


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
	my $user_id = session 'user_id';
	var user => &get_user($user_id);
	
	template 'change-picture.tt';
};
post '/c/change-picture' => sub {
	
	my $method = param 'picture';
	my $user_id = session 'user_id';
	my $user = schema->resultset('Users')->find($user_id);
	
	
	if ($method eq 'disk') {
		my $trap;
		my $newfile;
		if(  my $file  = request->upload('upfile') ) {
		
			my $type = $file->type;
			my $size = $file->size;
		
		
			my @allowed = ('image/jpeg');
			if (grep($type eq $_, @allowed)) {
								
				if ($size < 524288) {
				
					my $temp = $file->tempname;
				    
					my $image = Image::Resize->new($temp);
					my $gd = $image->resize(40, 40);
				
					my ($ext) = ($type =~ /^image\/(jpeg|gif|png)/);
					$newfile = (int rand 999 + 100) .'-'. time . ".$ext";
				
					open(my $fh,">","/home/infrared/dev/CiscoStudy/public/images/avatar/$newfile");
					binmode $fh;
					print $fh $gd->$ext;
					close $fh;
					
					my $update = $user->update({
						avatar_method => 'disk',
						avatar_value => $newfile,
					});
					if ($update->id) {
						var success => 1;
					}
					else {
						var error => 1;
					}
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
		else {
			var upload_error => 1;
		}
	}
	elsif ($method eq 'gravatar') {
		my $email = $user->email;
		if (!$email) {
			var missing_email => 1;
		}
		else {
			my $default;
			my $size = 40;
			my $avatar_value = md5_hex(lc $email);
			#my $avatar_url = "http://www.gravatar.com/avatar/". md5_hex(lc $user->email). "\?d=".uri_escape($default). "\&s=".$size;
			my $update = $user->update({
				avatar_method => 'gravatar',
				avatar_value => $avatar_value,
			});
			if ($update->id) {
				var success => 1;
			}
			else {
				var error => 1;
			}
		}
	}
	elsif ($method eq 'none') {
		$user->update({
			avatar_method => '',
			avatar_value => '',
		});
		if ($user->id) {
			var success => 1;
		}
		else {
			var error => 1;
		}
	}
	var user => &get_user($user_id);
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
get '/c/edit-simple-quiz/*' => sub {
	
	
	if (session('moderator')) {
		
		my ($quiz_id) = splat;
		session quiz_edit => $quiz_id;
		var id => $quiz_id;
		
		var categories => &categories;
		
		
		my $quiz = schema->resultset('SimpleQuiz')->find($quiz_id);
		
		my $hash = {
			cert_level => $quiz->cert_level,
			category => $quiz->category,
			question => $quiz->question,
			answer   => $quiz->answer,
			contributor => $quiz->contributor,
		};
		var quiz => $hash;
		

		template 'edit-simple-quiz.tt';
	}
	else {
		template 'permission-denied';
	}
};
post '/c/edit-simple-quiz/*' => sub {
	if (session('moderator')) {
		my ($quiz_id) = splat;
		
		if (session('quiz_edit') == $quiz_id) {
			
			my $cert_level = param 'cert_level';
			my $category   = param 'category';
			my $question   = param 'question';
			my $answer     = param 'answer';
			my $user_id    = session 'user_id';
			
			if ( length $cert_level && length $category && length $question && length $answer) {
				
				my $insert = schema->resultset('SimpleQuiz')->find($quiz_id)->update({
					cert_level => $cert_level,
					category   => $category,
					question   => $question,
					answer     => $answer,
					contributor => $user_id,
				});
				if ($insert->id) {
					var success => 1;
					var id => $insert->id;
					my $hash = {
						cert_level => $insert->cert_level,
						category => $insert->category,
						question => $insert->question,
						answer   => $insert->answer,
						contributor => $insert->contributor,
					};
					var quiz => $hash;
								
				}
				else {
					var error => 1;
				}
			}
			else {
				var formerror => 1;
			}
		}
		else {
			var iderror => 1;
		}
		var categories => &categories;
		template 'edit-simple-quiz.tt';
		
	}
	else {
		template 'permission-denied.tt';
	}
};

get '/c/delete-simple-quiz/*' => sub {
	if (session('moderator')) {
		my ($quiz_id) = splat;
		
		if (session('quiz_edit') == $quiz_id) {
			
			my $quiz = schema->resultset('SimpleQuiz')->find($quiz_id)->delete;
			
			if ($quiz->id) {
				var success => 1;
				session quiz_edit => undef;
			}
			else {
				var error => 1;
				
			}
		}
		else {
			var iderror => 1;
		}
		template 'delete-simple-quiz.tt';
	}
	else {
		template 'permission-denied.tt';
	}
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
			cert_level  => $cert_level,
			category    => $category,
			question    => $question,
			answer      => $answer,
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
		my @allowed = ('image/jpeg','image/png', 'image/gif');
		if (grep($type eq $_, @allowed)) {
			
			if ($size < 524288) {
				
				my ($ext) = ($type =~ /^image\/(jpeg|gif|png)/);
				$newfile = (int rand 999 + 100) .'-'. time . ".$ext";
		
				my $appdir = config->{appdir};
				$file->copy_to("$appdir/public/images/mc_quiz/$newfile");
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
	
	if (@{$list} > 0) {
	
	my $random = int rand (scalar @{ $list });
	
	my $id = @$list[$random];
	splice(@$list, $random,1);
	
	session list => $list;
	
	
	my $search = schema->resultset('MCQuiz')->find($id);
    if ($search) {
    
	var question => $search->question;
	
	my (@answers) = ($search->answer =~ /(\d+)/g);
	
	my $map = {
		1 => 'one',
		2 => 'two',
		3 => 'three',
		4 => 'four',
		5 => 'five',
		6 => 'six',
		7 => 'seven',
		8 => 'eight',
		9 => 'nine',
		10 => 'ten',
	};
	my $size = scalar @answers;
	
	var choose => $map->{$size};
	
	var image    => $search->image;
	my $date = $search->date_created;
	if (my $created = date($date)) {
		var date_created => $created;
		
		
	}
	var contributor => get_user($search->contributor);
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
	}
	else {
		var done => 1;
		session list => undef;
		session start => undef;
	}
	template 'quiz-multiple-choice';
	
};
get '/cisco-quiz-multiple-choice/*' => sub {
	
	my ($id) = splat;
	
	
	my $search = schema->resultset('MCQuiz')->find($id);
    if ($search) {
    
	var question => $search->question;
	my (@answers) = ($search->answer =~ /(\d+)/g);
	
	my $map = {
		1 => 'one',
		2 => 'two',
		3 => 'three',
		4 => 'four',
		5 => 'five',
		6 => 'six',
		7 => 'seven',
		8 => 'eight',
		9 => 'nine',
		10 => 'ten',
	};
	my $size = scalar @answers;
	
	var choose => $map->{$size};
	var image    => $search->image;
		my $date = $search->date_created;
	if (my $created = date($date)) {
		var date_created => $created;
		
		
	}
	var contributor => get_user($search->contributor);
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
	else {
		var wrong => 1;
		var id => $id;
	}

	template 'quiz-multiple-choice';
};


get '/quiz-menu' => sub {
	template 'quiz-menu.tt';
	
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
sub avatar {
	my $user_id = shift;
	my $user = schema->resultset('Users')->find($user_id);
	return $user->avatar_value;
	
}
sub date {
	
	my ($epoch) = shift;
	if (length session('timezone')) {
		
		my $dt = DateTime->from_epoch( epoch => $epoch )->set_time_zone( session('timezone') );
		
							   
		return sprintf("%3s %02d, %04d - %02d:%02d:%02d", $dt->month_abbr,$dt->day, $dt->year,$dt->hour,$dt->min,$dt->sec);

						   
	}
	else {
		return 0;
	}
	
	
}

sub get_user {
	my ($user_id) = shift;
	my $user = schema->resultset('Users')->find($user_id);
	
	my $email = $user->email;
	
	my $avatar_method = $user->avatar_method;
	my $avatar_value  = $user->avatar_value;
	my $avatar;
	if ($avatar_method eq 'disk') {
		$avatar = '/images/avatar/'. $avatar_value;
	}
	elsif ($avatar_method eq 'gravatar') {
		my $default;
		my $size = 40;
		$avatar = "http://www.gravatar.com/avatar/". $avatar_value. "\?d=".uri_escape($default). "\&s=".$size;
	}
	else {
		$avatar = undef;
	}
	my $hash = {
		username => $user->username,
		avatar_method => $user->avatar_method,
		avatar_value   => $user->avatar_value,
		avatar => $avatar,
		
	};
	
	return $hash;
}


true;
