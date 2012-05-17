package CiscoStudy::Routes::Index;

use strict;
use warnings;
use Dancer ':syntax';




get '/' => sub {
    template 'index.tt';
};


1;
