package CiscoStudy::Routes::Quiz;

use strict;
use warnings;
use Dancer::Plugin::DBIC;
use Dancer ':syntax';
use DateTime;
use List::Util 'shuffle';
use Array::Unique;

use CiscoStudy::Object::Category;
use CiscoStudy::Object::CertLevel;
use CiscoStudy::Object::Quiz;
use CiscoStudy::Object::Quiz::Image;
use CiscoStudy::Object::Quiz::MCQuiz;
use CiscoStudy::Object::User;
my $u_obj  = CiscoStudy::Object::User->new;
my $c_obj  = CiscoStudy::Object::Category->new;
my $cl_obj = CiscoStudy::Object::CertLevel->new;
my $im_obj = CiscoStudy::Object::Quiz::Image->new;
my $q_obj  = CiscoStudy::Object::Quiz->new;
#my $mc_obj = CiscoStudy::Object::Quiz::MCQuiz->new;



get '/cisco-quiz-menu' => sub {
    
    var certs       => $cl_obj->get_certs;
	var categories  => $c_obj->get_categories;
    #var contributors => $q_obj->get_contributors;
    template 'Quiz/quiz-menu.tt';
};



get '/c/edit-quiz/*' => sub {
    
	if (session('moderator')) {
        my ($quiz_id) = splat;
        session quiz_edit => $quiz_id;
        var certs       => $cl_obj->get_certs;
		var categories  => $c_obj->get_categories;
        
        my $quiz = schema->resultset('Quiz')->find($quiz_id);
        
		
		template 'Quiz/new-quiz.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
post '/c/edit-quiz' => sub {

    if (session('moderator')) {
        
        my $stop;
        my $cert_id  = param 'cert_id';
        my $category = param 'category';
        
        my $categories;
        if (ref $category eq 'ARRAY') {
            $categories = $category;
        }
        else {
            push (@$categories,$category);
        }
        
        $category = join(',',@$categories);
        
        
        if ($cert_id != 0) {
            
            
            if (@{$categories}) {
            
                my $image;
                if(  my $file  = request->upload('upfile') ) {
		
                    if ($image = $im_obj->upload_image($file)) {
                        var image => 1;
                    }
                    else {
                        $stop++;
                    }
                }
                if (!$stop) {
                    
                    my $quiztype = param 'quiztype';
                    
                    if ($quiztype eq 'MC') {
                    

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
                                        $stop++;
                                    }
                                }
                                my $x = 0;
                                foreach (@$options) {
                                    delete @$options[$x] unless length @$options[$x];
                                    $x++;
                                }
				
                                if (!$stop) {
	
=cut
| quiz_id      | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| date_created | int(14) unsigned | NO   |     | NULL    |                |
| quiz_type    | varchar(2)       | NO   |     | NULL    |                |
| question     | text             | NO   |     | NULL    |                |
| image        | varchar(250)     | YES  |     | NULL    |                |
| answer       | varchar(250)     | NO   |     | NULL    |                |
| answer_ios   | int(1) unsigned  | YES  |     | 0       |                |
| category     | varchar(250)     | NO   |     | NULL    |                |
| cert_level   | int(10) unsigned | NO   |     | NULL    |                |
| contributor  | int(14) unsigned | NO   |     | NULL    |                |
=cut
    
    				
                                    my $user_id 	= session 'user_id';
                                    my $cert_level 	= param 'cert_id';
                                    my $question 	= param 'mcquestion';
					
				
                                    my $time = time;
            
                                    my $data = {
                                        question => $question,
                                        date_created => $time,
                                        quiz_type => "MC",
                                        image => $image,
                                        answer => '',
                                        category => $category,
                        				cert_level => $cert_level,
                                		contributor => $user_id,
                            		};
	
                                    my $insert = schema->resultset('Quiz')->create($data);
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
                                # not enough options?!
                                var invalid_form => 1;
                            }
                        }
                        else {
                            # no answers
                            var invalid_form => 1;
                        }
                    }
                    elsif ($quiztype eq 'TF') {
                        
                        my $answer   = param 'tfradio';
                        my $question = param 'tfquestion';
                        my $user_id 	= session 'user_id';
                        my $cert_level 	= param 'cert_id';
                        
					
				
                        my $time = time;
            
                        my $data = {
                            question => $question,
                            date_created => $time,
                            quiz_type => "TF",
                            image => $image,
                            answer => $answer,
                            category => $category,
                        	cert_level => $cert_level,
                            contributor => $user_id,
                        };
                        my $insert = schema->resultset('Quiz')->create($data);
                        if ($insert->id) {
                            var success => $insert->id;
                        }
                        else {
                            var error => 1;
                        }
                        
                    }
                    elsif ($quiztype eq 'FC') {
                        
                        my $answer      = param 'fcanswer';
                        my $question    = param 'fcquestion';
                        my $user_id 	= session 'user_id';
                        my $cert_level 	= param 'cert_id';
                        
					
				
                        my $time = time;
            
                        my $data = {
                            question => $question,
                            date_created => $time,
                            quiz_type => "FC",
                            image => $image,
                            answer => $answer,
                            category => $category,
                        	cert_level => $cert_level,
                            contributor => $user_id,
                        };
                        my $insert = schema->resultset('Quiz')->create($data);
                        if ($insert->id) {
                            var success => $insert->id;
                        }
                        else {
                            var error => 1;
                        }
                        
                    }
                    elsif ($quiztype eq 'BA') {
                        
                        my $answer      = param 'baanswer';
                        my $question    = param 'baquestion';
                        my $user_id 	= session 'user_id';
                        my $cert_level 	= param 'cert_id';
                        my $answer_ios  = param 'baanswer_type';
                        
					
				
                        my $time = time;
            
                        my $data = {
                            question => $question,
                            date_created => $time,
                            quiz_type => "BA", #basic
                            image => $image,
                            answer => $answer,
                            answer_ios => $answer_ios,
                            category => $category,
                        	cert_level => $cert_level,
                            contributor => $user_id,
                        };
                        my $insert = schema->resultset('Quiz')->create($data);
                        if ($insert->id) {
                            var success => $insert->id;
                        }
                        else {
                            var error => 1;
                        }
                        
                    }
                }
                else {
                    # error with image?
                    var invalid_form => 1;
                }
            }
            else {
                var invalid_form => 1;
            }
        }
        
        var certs => $cl_obj->get_certs;
        var categories  => $c_obj->get_categories;
	
        template 'Quiz/new-quiz.tt';
    }
    else {
        template 'permission-denied.tt';
    }
	
};
post '/c/new-quiz' => sub {

    if (session('contributor')) {
        
        my $stop;
        my $cert_id  = param 'cert_id';
        my $category = param 'category';
        
        my $categories;
        if (ref $category eq 'ARRAY') {
            $categories = $category;
        }
        else {
            push (@$categories,$category);
        }
        
        $category = join(',',@$categories);
        
        
        if ($cert_id != 0) {
            
            
            if (@{$categories}) {
            
                my $image;
                if(  my $file  = request->upload('upfile') ) {
		
                    if ($image = $im_obj->upload_image($file)) {
                        var image => 1;
                    }
                    else {
                        $stop++;
                    }
                }
                if (!$stop) {
                    
                    my $quiztype = param 'quiztype';
                    
                    if ($quiztype eq 'MC') {
                    

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
                                        $stop++;
                                    }
                                }
                                my $x = 0;
                                foreach (@$options) {
                                    delete @$options[$x] unless length @$options[$x];
                                    $x++;
                                }
				
                                if (!$stop) {
	
=cut
| quiz_id      | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| date_created | int(14) unsigned | NO   |     | NULL    |                |
| quiz_type    | varchar(2)       | NO   |     | NULL    |                |
| question     | text             | NO   |     | NULL    |                |
| image        | varchar(250)     | YES  |     | NULL    |                |
| answer       | varchar(250)     | NO   |     | NULL    |                |
| answer_ios   | int(1) unsigned  | YES  |     | 0       |                |
| category     | varchar(250)     | NO   |     | NULL    |                |
| cert_level   | int(10) unsigned | NO   |     | NULL    |                |
| contributor  | int(14) unsigned | NO   |     | NULL    |                |
=cut
    
    				
                                    my $user_id 	= session 'user_id';
                                    my $cert_level 	= param 'cert_id';
                                    my $question 	= param 'mcquestion';
					
				
                                    my $time = time;
            
                                    my $data = {
                                        question => $question,
                                        date_created => $time,
                                        quiz_type => "MC",
                                        image => $image,
                                        answer => '',
                                        category => $category,
                        				cert_level => $cert_level,
                                		contributor => $user_id,
                            		};
	
                                    my $insert = schema->resultset('Quiz')->create($data);
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
                                # not enough options?!
                                var invalid_form => 1;
                            }
                        }
                        else {
                            # no answers
                            var invalid_form => 1;
                        }
                    }
                    elsif ($quiztype eq 'TF') {
                        
                        my $answer   = param 'tfradio';
                        my $question = param 'tfquestion';
                        my $user_id 	= session 'user_id';
                        my $cert_level 	= param 'cert_id';
                        
					
				
                        my $time = time;
            
                        my $data = {
                            question => $question,
                            date_created => $time,
                            quiz_type => "TF",
                            image => $image,
                            answer => $answer,
                            category => $category,
                        	cert_level => $cert_level,
                            contributor => $user_id,
                        };
                        my $insert = schema->resultset('Quiz')->create($data);
                        if ($insert->id) {
                            var success => $insert->id;
                        }
                        else {
                            var error => 1;
                        }
                        
                    }
                    elsif ($quiztype eq 'FC') {
                        
                        my $answer      = param 'fcanswer';
                        my $question    = param 'fcquestion';
                        my $user_id 	= session 'user_id';
                        my $cert_level 	= param 'cert_id';
                        
					
				
                        my $time = time;
            
                        my $data = {
                            question => $question,
                            date_created => $time,
                            quiz_type => "FC",
                            image => $image,
                            answer => $answer,
                            category => $category,
                        	cert_level => $cert_level,
                            contributor => $user_id,
                        };
                        my $insert = schema->resultset('Quiz')->create($data);
                        if ($insert->id) {
                            var success => $insert->id;
                        }
                        else {
                            var error => 1;
                        }
                        
                    }
                    elsif ($quiztype eq 'BA') {
                        
                        my $answer      = param 'baanswer';
                        my $question    = param 'baquestion';
                        my $user_id 	= session 'user_id';
                        my $cert_level 	= param 'cert_id';
                        my $answer_ios  = param 'baanswer_type';
                        
					
				
                        my $time = time;
            
                        my $data = {
                            question => $question,
                            date_created => $time,
                            quiz_type => "BA", #basic
                            image => $image,
                            answer => $answer,
                            answer_ios => $answer_ios,
                            category => $category,
                        	cert_level => $cert_level,
                            contributor => $user_id,
                        };
                        my $insert = schema->resultset('Quiz')->create($data);
                        if ($insert->id) {
                            var success => $insert->id;
                        }
                        else {
                            var error => 1;
                        }
                        
                    }
                }
                else {
                    # error with image?
                    var invalid_form => 1;
                }
            }
            else {
                var invalid_form => 1;
            }
        }
        
        var certs => $cl_obj->get_certs;
        var categories  => $c_obj->get_categories;
	
        template 'Quiz/new-quiz.tt';
    }
    else {
        template 'permission-denied.tt';
    }
	
};

post '/cisco-quiz-menu' => sub {
    
    my $cert_id  = param 'cert_id';
    my $category = param 'category';
    my $quiz_type = param 'quiztype';
    
    
    my @categories;
    if (ref $category ne 'ARRAY') {
        push (@categories,$category);
    }
    else {
        @categories = @$category;
    }
    
    
    my @quiz_types;
    if (ref $quiz_type ne 'ARRAY') {
        push(@quiz_types,$quiz_type);
    }
    else {
        @quiz_types = @$quiz_type;
    }
    
    my @query;
    
    foreach (@quiz_types) {
        my $hash = {
            quiz_type => $_,
        };
        push (@query,$hash);
        
    }
    
    
    session quiz_cert_id => $cert_id;
    session quiz_category => \@categories;
    session quiz_type => \@quiz_types;
    session start => time;
    
    
    my $all = schema->resultset('Quiz')->search({
        -and => [
            -or => \@query,
            cert_level => $cert_id,
        ],
  
    });
    
	if ($all->count) {
        tie my @list, 'Array::Unique';
		while (my $row = $all->next) {


            my (@cats) = ($row->category =~ /(\d+)/g);
            
            for my $cat (@categories) {
                if (grep($cat == $_, @cats)) {
                    push(@list,$row->quiz_id);

                }
            }

		}
		session list => \@list;

	}
   
    redirect '/cisco-quiz';
	
};


get '/cisco-quiz' => sub {
    
    if (!session('start') || !session('quiz_cert_id') || !session('quiz_category') || !session('quiz_type')) {
        redirect '/cisco-quiz-menu';
    }
	else {
	
        my $list = session('list');
	
        if (@{$list} > 0) {
	
            my $random = int rand (scalar @{ $list });
	
            my $id = @$list[$random];
            splice(@$list, $random,1);
	
            session list => $list;
            session current_quiz => $id;
	
	
            my $search = schema->resultset('Quiz')->find($id);
            if ($search) {
                
                
                if ($search->quiz_type eq 'MC') {
                    session correct => undef;
                    session wrong => undef;
    
                    var quiz_type => 'MC';
                    var question => $search->question;
                    var answer   => $search->answer;
                    session q_answer => $search->answer;    # To be used to check answer
                    session q_type   => $search->quiz_type; # To be used to check answer

                    
	
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
                }
                elsif ($search->quiz_type eq 'TF') {
                    session correct => undef;
                    session wrong => undef;
                    session q_answer => $search->answer;    # To be used to check answer
                    session q_type   => $search->quiz_type; # To be used to check answer
                    var quiz_type => 'TF';
                    var question => $search->question;
                    
                }
                elsif ($search->quiz_type eq 'FC') {
                    session correct => undef;
                    session wrong => undef;
                                        var question => $search->question;
                    var answer   => $search->answer;
                    var quiz_type => 'FC';
                    
                    
                    
                }
                var image    => $search->image;
                my $date = $search->date_created;
                if (my $created = date($date)) {
                    var date_created => $created;
                }
                var contributor => $u_obj->get_user($search->contributor);
        	}   
        }
        else {
            var done => 1;
            session list => undef;
            session start => undef;
        }
    }

	template 'Quiz/cisco-quiz.tt';
	
};

post '/cisco-quiz' => sub {
    if (session('current_quiz')) {
        
        my $quiz_id    = session('current_quiz');
        my $quiz_type  = session('q_type');
        my $answer     = session('q_answer');
        
        if ($quiz_type eq 'MC') {
            
            my $guess = param 'option';
          	my @guesses;
            if (ref $guess eq 'ARRAY') {
                @guesses = @{ $guess };
	    	}
            else {
                push(@guesses,$guess);
            }
            my (@answers) = ($answer =~ /(\d+)/g);
	
            my $compare = Array::Compare->new;
	
            if ($compare->perm( \@guesses, \@answers)) {
                session correct => 1;
		
            }
            else {
                session wrong => 1;
                
            }
        }
        elsif ($quiz_type eq 'TF') {
            
            my $guess = param 'tfradio';
            if ($guess eq $answer) {
                session correct => 1;
            }
            else {
                session wrong => 1;
                
            }
            
        }
    }
	template 'Quiz/cisco-quiz.tt';
};        
        
        

get '/cisco-quiz/*' => sub {
    
    my ($id) = splat;
    

    my $search = schema->resultset('Quiz')->find($id);
    if ($search) {
                
                
        if ($search->quiz_type eq 'MC') {
            session correct => undef;
            session wrong => undef;
    
            var quiz_type => 'MC';
            var question => $search->question;
            var answer   => $search->answer;
            session q_answer => $search->answer;    # To be used to check answer
            session q_type   => $search->quiz_type; # To be used to check answer

                    
	
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
        }
        elsif ($search->quiz_type eq 'TF') {
            session correct => undef;
            session wrong => undef;
            session q_answer => $search->answer;    # To be used to check answer
            session q_type   => $search->quiz_type; # To be used to check answer
            var quiz_type => 'TF';
            var question => $search->question;
                    
        }
        elsif ($search->quiz_type eq 'FC') {
            session correct => undef;
            session wrong => undef;
            var question => $search->question;
            var answer   => $search->answer;
            var quiz_type => 'FC';
                
        }
        var image    => $search->image;
        my $date = $search->date_created;
        if (my $created = date($date)) {
            var date_created => $created;
        }
        var contributor => $u_obj->get_user($search->contributor);
  	}   
    else {
        var unknown => 1;
    }


	template 'Quiz/cisco-quiz.tt';
	
};





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

1;
