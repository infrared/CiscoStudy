package CiscoStudy::Object::Quiz;

use strict;
use warnings;

use Dancer::Plugin::DBIC;
use CiscoStudy::Object::User;

my $u_obj = CiscoStudy::Object::User->new;
use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}


sub get_contributors {
    
    my $self = shift;
    
    my $search = schema->resultset('Quiz')->search(undef,{
        select => [qw/ contributor cert_level /],
        distinct => 1,
           
    });
    my @users;
    my $hash;
    if ($search->count) {
        while(my $row = $search->next) {
            my $user_id = $row->contributor;
            my $cert_level = $row->cert_level;
            
            my $user = $u_obj->get_user($user_id);
            $hash->{users}{$user}{username} = $user->{username};
            $hash->{users}{$user}{count}++;
        
            push( @{ $hash->{$cert_level}{'contributors'} },$user);
      

        }
    }
    return $hash;
}
1;
