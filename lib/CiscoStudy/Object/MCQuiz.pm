package CiscoStudy::Object::MCQuiz;
use strict;
use warnings;
use Dancer::Plugin::DBIC;

use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub count {
    
    my ($self,$hash) = @_;
    
    ####
    
    #  $hash = { cert_level => 1 }
    
    #
    return 0 unless (ref $hash eq 'HASH');
    
    my $count = schema->resultset('MCQuiz')->search($hash)->count;
    
    return $count;
    
}




1;
