package CiscoStudy::Routes::Category;

use strict;
use warnings;
use Dancer ':syntax';




get '/c/categories' => sub {
	if (session('moderator')) {
		var categories => &categories;
		template 'categories.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
get '/c/new-category' => sub {
	if (session('moderator')) {
		template 'new-category.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
post '/c/new-category' => sub {
	if (session('moderator')) {
		my $category = param 'category';
		my $search = schema->resultset('Category')->search({ category => $category });
		if ($search->count) {
			var cat_exists => 1;
	
		}
		else {
			my $insert = schema->resultset('Category')->create({ category => $category });
			if ($insert->id) {
				var success => 1;
			}
		}
		template 'new-category.tt';
	}
	else {
		template 'permission-denied.tt';
	}
};
1;
