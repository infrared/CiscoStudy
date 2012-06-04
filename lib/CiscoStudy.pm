package CiscoStudy;

use Database::Main;
use Dancer::Plugin::DBIC;

use Dancer ':syntax';
use Array::Compare;
#use Crypt::PasswdMD5;




#use DateTime::TimeZone

our $VERSION = '0.1';

hook 'before' => sub {
    if (request->path_info =~ m{^/c\/} && !session('authenticated') ) {
        request->path_info('/login');
    }
};

use CiscoStudy::Routes::Index;
use CiscoStudy::Routes::Login;
use CiscoStudy::Routes::Profile;
use CiscoStudy::Routes::Logout;
use CiscoStudy::Routes::IRC;
use CiscoStudy::Routes::CertLevel;
use CiscoStudy::Routes::Category;
use CiscoStudy::Routes::Quiz;
use CiscoStudy::Routes::User;
use CiscoStudy::Routes::Forum;



true;
