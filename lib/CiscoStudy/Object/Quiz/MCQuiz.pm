package CiscoStudy::Object::Quiz::MCQuiz;
=cut
use strict;
use warnings;

use Dancer::Plugin::DBIC;
use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}


sub new_quiz {
    
    my($question,$options,$image,$answer,$category,$cert_id) = @_;
    my @answers;
    
		
    



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

=cut

1;
