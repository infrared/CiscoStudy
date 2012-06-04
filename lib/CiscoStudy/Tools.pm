package CiscoStudy::Tools;
use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Dancer::Plugin::DBIC;
use Dancer ':syntax';

use DateTime;
sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub date {
	
	my ($self,$epoch) = @_;
	if ( (session('timezone')) && (length session('timezone'))) {
		
		my $dt = DateTime->from_epoch( epoch => $epoch )->set_time_zone( session('timezone') );
		
							   
		return sprintf("%3s %02d, %04d - %02d:%02d:%02d", $dt->month_abbr,$dt->day, $dt->year,$dt->hour,$dt->min,$dt->sec);

						   
	}
	else {
        
		my $dt = DateTime->from_epoch( epoch => $epoch )->set_time_zone('America/New_York');
		
							   
		return sprintf("%3s %02d, %04d - %02d:%02d:%02d", $dt->month_abbr,$dt->day, $dt->year,$dt->hour,$dt->min,$dt->sec);

	}
	
	
}


1;
