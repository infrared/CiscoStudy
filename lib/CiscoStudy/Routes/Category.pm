package CiscoStudy::Routes::Category;

use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;

use CiscoStudy::Object::Category;
use CiscoStudy::Object::CertLevel;

my $c_obj  = CiscoStudy::Object::Category->new;
my $cl_obj = CiscoStudy::Object::CertLevel->new;




get '/c/categories' => sub {
	if (session('moderator')) {
        var certs => $cl_obj->get_certs;
		var categories  => $c_obj->get_categories;
		template 'categories.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
get '/c/new-category/*' => sub {
	if (session('moderator')) {
        my ($cert_id) = splat;
        if (my $cert = $cl_obj->get_cert($cert_id)) {
            var cert_name => $cert->{cert_name };
        }
		template 'new-category.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
post '/c/new-category/*' => sub {
	if (session('moderator')) {
        my ($cert_id) = splat;
        if (my $cert = $cl_obj->get_cert($cert_id)) {
            var cert_name => $cert->{cert_name };
        
            my $category = param 'category';
            my $search = schema->resultset('Category')->search({ cert_level => $cert_id, category => $category });
            if ($search->count) {
                var cat_exists => 1;
	
            }
            else {
                my $insert = schema->resultset('Category')->create({ cert_level => $cert_id, category => $category });
                if ($insert->id) {
                    var success => 1;
                    redirect '/c/categories';
                }
            }
        }
        else {
            var error => "uh oh";
        }
       	template 'error.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
1;
