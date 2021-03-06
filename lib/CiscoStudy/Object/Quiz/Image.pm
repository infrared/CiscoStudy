package CiscoStudy::Object::Quiz::Image;
use strict;
use warnings;

use Dancer ':syntax';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}


sub upload_image {
    
    my ($self,$file) = @_;


    my $type = $file->type;
	my $size = $file->size;
	my @allowed = ('image/jpeg','image/png', 'image/gif');
	if (grep($type eq $_, @allowed)) {
			
        if ($size < 524288) {
			
            my $newfile;
            
            my ($ext) = ($type =~ /^image\/(jpeg|gif|png)/);
            
            my $random = (int rand 999) + 100;
            my $appdir = config->{appdir};
            #mkdir "$appdir/public/images/quiz/$random";
			$newfile = $random .'-'. time . ".$ext";
		

			$file->copy_to("$appdir/public/images/quiz/$newfile");
            return $newfile if (-e "$appdir/public/images/quiz/$newfile");
            
            return 0;
		}
		else {
            return 0;
				
		}
	}
	else {
        return 0;
	}
}


1;
