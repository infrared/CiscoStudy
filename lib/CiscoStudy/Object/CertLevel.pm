package CiscoStudy::Object::CertLevel;
use strict;
use warnings;
use Dancer::Plugin::DBIC;

use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub get_cert {
    
    my ($self,$cert) = @_;
    
    my $find = schema->resultset('CertLevel')->find($cert);
    
    if ($find) {
        my $hash = {
            cert_id => $find->cert_id,
            cert_name => $find->cert_name,
            
        };
        return $hash;
    }
    else {
        return 0;
    }
    
}
sub update_cert {
    my ($self,$cert_id,$cert_name) = @_;
    
    my $find = schema->resultset('CertLevel')->find($cert_id);
    
    if ($find) {
        $find->update({ cert_name => $cert_name });
        return 1;
    }
    else {
        return 0;
    }
    
}
sub delete_cert {
    my ($self,$cert_id) = @_;
    
    my $find = schema->resultset('CertLevel')->find($cert_id);
    if ($find) {
        $find->delete;
        return 1;
    }
    else {
        return 0;
    }
 
   
}
sub get_certs {
    
    my ($self) = @_;
    my $search = schema->resultset('CertLevel')->search;
    
    my @certs;
    
    if ($search->count) {
        
        while(my $row = $search->next) {
            my $hash = {
                cert_id => $row->cert_id,
                cert_name => $row->cert_name,
            };
            push(@certs,$hash);
                
        
        }
        
    }
    return \@certs;
}
sub get_certs_hashref {
    
    my ($self) = @_;
    my $search = schema->resultset('CertLevel')->search;
    
    my $certs;
    
    if ($search->count) {
        
        while(my $row = $search->next) {
            my $id = $row->cert_id;
            $certs->{$id}{cert_name} = $row->cert_name;
      
        }
        
    }
    return $certs;
    
    
    
}

sub add_cert {
    my ($self,$cert) = @_;
    
    if (length $cert) {
        
        my $search = schema->resultset('CertLevel')->search({ cert_name => $cert });
        
        if ($search->count) {
            return 0;
        }
        else {
            my $create = schema->resultset('CertLevel')->create({ cert_name => $cert });
            
            if ($create->id) {
                return $create->id;
            }
            else {
                return 0;
            }
            
        }
        
        
    }
    else {
        return 0;
    }
}


1;
