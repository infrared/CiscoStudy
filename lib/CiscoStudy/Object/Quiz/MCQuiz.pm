package CiscoStudy::Object::Category;
use strict;
use warnings;

use Dancer::Plugin::DBIC;
use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub get_categories {
    

	my $cat = schema->resultset('Category')->search;
	my @categories;
	while(my $row = $cat->next) {
		my $hash = {
			cat_id => $row->cat_id,
            cert_level => $row->cert_level,
			category => $row->category,
		};
		push(@categories,$hash);
	}
	
	return \@categories;
}



1;
