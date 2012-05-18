package CiscoStudy::Routes::CertLevel;

use strict;
use warnings;
use Dancer ':syntax';


use CiscoStudy::Object::CertLevel;
use CiscoStudy::Object::MCQuiz;


my $cl_obj = CiscoStudy::Object::CertLevel->new;
my $mc_obj = CiscoStudy::Object::MCQuiz->new;


get '/c/cert-levels' => sub {
	
    
    session edit_cert => undef;
    
    var certs => $cl_obj->get_certs;
        
    template 'cert-levels.tt';
};

post '/c/cert-levels' => sub {
    
    if (session('moderator')) {
        
        my $cert_name = param 'cert_name';
        
        
        if (my $id = $cl_obj->add_cert($cert_name)) {
            var success => $id;
        }
        else {
            var error => 1;
        }
        var certs => $cl_obj->get_certs;
        template 'cert-levels.tt';
        
    }
    else {
        template 'permission-denied.tt';
    }
      
};
get '/c/edit-cert-level/*' => sub {
    
    my ($cert_id) = splat;
    
    if (my $cert = $cl_obj->get_cert($cert_id)) {
        
        session edit_cert => $cert->{cert_id};
        var cert => $cert;
    }
    else {
        var error => 1;
    }
    
    template 'edit-cert-level.tt';

   
};

post '/c/edit-cert-level/*' => sub {
    
    my ($cert_id) = splat;
    
    if (session('edit_cert') == $cert_id) {
        
        my $cert_name = param 'cert_name';
        
        # no funny business
        if ($cl_obj->update_cert($cert_id,$cert_name)) {
            redirect '/c/cert-levels';#request->path_info('/c/cert-levels');
            var success => 1;
        }
        else {
            var error => 1;
        }
        
        
    }
    else {
        var tamper => 1;
    }
    template 'edit-cert-level.tt';
   
};

get '/c/delete-cert-level' => sub {
    
    if (session('edit_cert')) {
        
        my $cert_id = session('edit_cert');
        
        my $hash = { cert_level => $cert_id };
        
        if ($mc_obj->count($hash)) {
            
            var inuse => 1;
            
        }
        else {
            if ($cl_obj->delete_cert($cert_id)) {
                var success => 1;
            }
            else {
                var error => 1;
            }
                    
        }
        template 'delete-cert-level.tt';
    }
};


1;
