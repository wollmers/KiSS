package Kiss::Gallery::Image;

use strict;
use warnings;

use v5.10.1;

use File::Spec;
use Image::Magick;
use Data::Dumper;

#use parent qw( Kiss::Gallery );

sub new {
	my $class = shift;
	my $home = shift;
	my $self = {};
	bless($self, $class);
	
	$self->home($home);
	
	return $self;
}

sub home {
  my $self = shift;
  my $home = shift;
  
  if (defined $home && -d $home) { 
    $self->{home} = $home;
  } 
  if (defined $self->{home}) {
    return $self->{home}; 
  }
  elsif (defined $ENV{'DOCUMENT_ROOT'}) {
    $self->{home} = $ENV{'DOCUMENT_ROOT'};
  }
  return $self->{home};
}

sub folder {
	my $self = shift;

  if (defined $self->{folder}) {
    return $self->{folder};
  }
  $self->{folder} = $self->home() . '/' . 'pub/gallery';
	return $self->{folder};
}

sub folders {
	my $self = shift;

  if (defined $self->{folders}) {
    return defined $self->{folders};
  }
  my $folder = $self->folder();
  print 'folders() $folder:',$folder,"\n";
  my $sizes = $self->sizes();
  
  for my $size (@$sizes) {
    my $path = $folder.'/'. ${ $size }[0];
    unless (-d $path) {
			mkdir ( $path ) or die "Cannot create directory: ".$path." $!";
		}
		push @{$self->{folders}},$path;
  } 
	return $self->{folders};
}

sub sizes {
  my $self = shift;
  if (defined $self->{sizes}) {
    return $self->{sizes};
  }
  $self->{sizes} = [
    # width x height
		[".tmb", "40x40" ],
		[ ".s", "110x110" ],
		[ ".m", "205x205" ],
		[ ".l", "410x410" ],
	];
	$self->folders();
	return $self->{sizes};
}

sub variations {	
	my $self = shift;
	my $file = shift;

  print 'variations() called with $file: ',$file,"\n";

	return '' unless (-f $file); 
		
	my $image=Image::Magick->new();
	my $err = $image->Read( $file );	
	print '$image->Read $err: ',$err,"\n" if ($err);

  my (undef,undef,$filename) = File::Spec->splitpath($file);

  my ($width, $height) = $image->Get('width', 'height');

	my $variations = $self->sizes();
		
	for my $variation ( @$variations ) {
		my $image_clone = $image->clone();
		$image_clone->Resize( geometry => ${ $variation }[1] );
	
		my $targetfile = File::Spec->canonpath( $self->folder() ."/".${ $variation }[0]."/".$filename );
		print 'write image to ',$targetfile,"\n";
		my $err = $image_clone->Write( 'filename' => $targetfile );
		
		return '' if $err;
		undef $image_clone;
	}
	undef $image;
}

sub convert_all {
  my $self = shift;
  
  my $path = $self->folder();
  opendir (my $fh, $path) or die "Cannot open directory: ".$path." $!";;
  my @items = grep { $_ !~ /^\.[.]?$/ } readdir $fh;
  closedir $fh;
  
  my @files = grep { -f "$path/$_" && /\.JPG$/i } @items;
  
  print '@files: ',Dumper(\@files),"\n";
  for my $file (@files) {
    $self->variations("$path/$file");
  }
}

1;

