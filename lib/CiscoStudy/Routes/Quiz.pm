package CiscoStudy::Routes::Quiz;

use strict;
use warnings;
use Dancer::Plugin::DBIC;
use Dancer ':syntax';

use CiscoStudy::Object::Category;
use CiscoStudy::Object::CertLevel;
use CiscoStudy::Object::Quiz::Image;
my $c_obj  = CiscoStudy::Object::Category->new;
my $cl_obj = CiscoStudy::Object::CertLevel->new;
my $im_obj = CiscoStudy::Object::Quiz::Image->new;



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

    if (session('contributor') {
        
        my $trap;
        my $cert_id  = param 'cert_id';
        my $category = param 'category';
        
        my $categories;
        if (ref $category eq 'ARRAY') {
            $categories = $category;
        }
        else {
            push (@$categories,$category);
        }
        
        if ($cert_id != 0) {
            
            
            if (@{$categories}) {
            
            my $image;
        	if(  my $file  = request->upload('upfile') ) {
		
                if ($image = $im_obj->upload_image($file)) {
                    var image => 1;
                }
                else {
                    $trap++;
                }
            }
            if (!$trap) {
    
                my $quiztype = param 'quiztype';
        

                if ($quiztype eq 'MC') {
                    
                    my ($answer)  = param 'id';
                    my ($options) = param 'option';
		

			
			
			
			my ($options) =  param 'option';
			

				
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



1;
