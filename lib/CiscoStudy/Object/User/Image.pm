package CiscoStudy::Object::User::Image;
use strict;
use warnings;

use Dancer ':syntax';
use Image::Resize;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}


sub upload_image {
    
    my ($self,$file) = @_;

    my $user    = session('username');
    my $user_id = session('user_id');
    
    my ($first) = ($user =~ /(\w)/);
    
    $first = lc $first;

    my $type = $file->type;
	my $size = $file->size;
	my @allowed = ('image/jpeg','image/png', 'image/gif');
	if (grep($type eq $_, @allowed)) {
			
        if ($size < 524288) {
            
            my $temp = $file->tempname;
            my $image = Image::Resize->new($temp);
            my $gd = $image->resize(85,85);
			
                        
            my ($ext) = ($type =~ /^image\/(jpeg|gif|png)/);
            
            my $random = (int rand 999) + 100;
            my $appdir = config->{appdir};
            if (!-d "$appdir/public/images/avatar/$first") {
                mkdir "$appdir/public/images/avatar/$first";
            }
            
			my $newfile = $user_id . ".$ext";
            
            open(my $fh,">","$appdir/public/images/avatar/$first/$newfile");
            binmode $fh;
            print $fh $gd->$ext;
            close $fh;
	


            return $newfile if (-e "$appdir/public/images/avatar/$first/$newfile");
            
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
