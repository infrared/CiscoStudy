package CiscoStudy::Routes::Quiz;

use strict;
use warnings;
use Dancer::Plugin::DBIC;
use Dancer ':syntax';

use CiscoStudy::Object::Category;
use CiscoStudy::Object::CertLevel;
use CiscoStudy::Object::Quiz::Image;
use CiscoStudy::Object::Quiz::MCQuiz;
my $c_obj  = CiscoStudy::Object::Category->new;
my $cl_obj = CiscoStudy::Object::CertLevel->new;
my $im_obj = CiscoStudy::Object::Quiz::Image->new;
#my $mc_obj = CiscoStudy::Object::Quiz::MCQuiz->new;



get '/cisco-quiz' => sub {
    
    var certs       => $cl_obj->get_certs;
	var categories  => $c_obj->get_categories;
    template 'Quiz/quiz-menu.tt';
};



get '/c/new-quiz' => sub {
	if (session('contributor')) {
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



1;
